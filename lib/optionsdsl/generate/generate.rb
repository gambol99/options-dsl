#!/usr/bin/ruby
#
# Author: Rohith 
# Date:   2014-03-02 23:24:32
# Last Modified by:   Rohith
#
# vim:ts=4:sw=4:et
#
require 'optparse'

module OptionsDSL
class Generate
    attr_reader :parser

    def initialize(rules, options = {})
      @rules = rules
      @parser = parsers rules
      @options = options
      @cursor = @options
    end

    def parse!(arguments = ARGV)
      begin
        # step: we need to group the command into batches and process via the respective parser
        batches = process_batches arguments
        #PP.pp batches
        batches.each_pair do |command, batch|
          @rules.parser[command].parse! batch[:arguments]
        end
      rescue SystemExit => e
        raise SystemExit
      rescue ArgumentError => e
        Logger.error 'parse! argument error: %s' % [e.message]
        raise ArgumentError, e.message
      rescue Exception => e
        raise Exception, e.message
      end
      @options
    end

    private
    # description: the method carves up the command line options into the respective processors
    def process_batches(arguments, &block)
      # step: we setup the batches for filling in later
      batches = @rules.commands.keys.inject({}) do |h, arg|
        h[arg] = {:arguments => [], :switches => {}, :selected => false}
        h
      end
      # step: global is always turned on
      cursor = batches[:global]
      cursor[:selected] = true
      # step: we iterate the arguments and seperate them into their batch
      arguments.map do |x|
        if batches.include? x.to_sym
          cursor = batches[x.to_sym]
          cursor[:selected] = true
        else
          cursor[:arguments] << x
          cursor[:switches][x] = true if x =~ /^-{1,2}/
        end
      end
      # step: if the we are --help|-h .. lets bypasss the rest, as it's useless
      if batches.select { |k, v| v[:switches] if v[:switches]['--help'] or v[:switches]['-h'] }.size >= 1
        return batches
      end

      # step: iterate the batch (command) and add any options which have defaults and check added
      batches.each_pair do |command, batch|
        # we don't care about a command that has not been selected
        next unless batch[:selected]
        # step: we iterate the input for this command
        @rules.commands[command].inputs.each_pair do |input_name, input|
          next if input.optional
          short_switch = $1 if input.options.short and input.options.short =~ /(-{1,2}[[:alpha:]]+) /
          long_switch = $1 if input.options.short and input.options.long =~ /(-{1,2}[[:alpha:]]+) /
          switch_exists = (!batch[:switches].has_key? short_switch and !batch[:switches].has_key? long_switch) ? false : true
          #puts "input: %s, switch_exists: %s, short: %s, long: %s" % [ input_name, switch_exists, short_switch, long_switch ]
          # check: if we don't have :defaults on the input and the switch has not set - throw require argument
          if !switch_exists and !input.defaults
            raise ArgumentError, 'the argument %s (%s/%s) is a required parameter, please check usage' %
                [input.name, input.options.short, input.options.long]
          end
          # step: we can bypass this one if it's already set
          next if switch_exists
          # step: the argument is not specified but the input has a :defaults - hence we inject the parameters
          # in as if was passed on the command line.
          batch[:switches][short_switch || long_switch] = true
          batch[:arguments] << short_switch || long_switch
          batch[:arguments] << input.defaults
        end
      end
      batches
    end

    # method: takes the dsl structure and generates the parsers from it
    def parsers(rules = @rules)
      @parser = {}
      begin
        if rules.commands.has_key? :global
          global = rules.commands[:global]
          rules.parser[:global] = ::OptionParser::new do |o|
            o.banner = "\tscript [global options] [subcommand] [options]"
            o.separator ''
            o.separator "\tGlobal Options:"
            o.separator "\t==============="
            o.separator ''
            global.inputs.each_pair do |name, input|
              o.on(input.options.short, input.options.long, input.description) do |x|
                validate_input input, x
              end
            end
            if rules.commands.size > 1
              o.separator ''
              o.separator "\tSubcommands: script subcommand [options]"
              o.separator "\t========================================"
              o.separator ''
            end
            o.on('-h', '--help', 'display the help usage menu') do
              puts rules.parser[:global]
              rules.commands.each_pair do |name, command|
                next if command.name == :global
                puts rules.parser[command.name]
              end
              exit 0
            end
          end
        end
        rules.commands.values.each do |c|
          next if c.name == :global
          rules.parser[c.name] = ::OptionParser::new do |o|
            o.banner = ''
            o.separator "\tcommand: [%s]:    %s\n" % [c.name, c.description]
            o.separator ''
            c.inputs.each_pair do |name, input|
              o.on(input.options.short, input.options.long, input.description) do |x|
                validate_input input, x if defined? x
              end
              o.on('-h', '--help', 'display the help usage menu') do
                puts rules.parser[c.name]
                exit 0
              end
            end
          end
        end
      rescue SystemExit => e
        raise SystemExit
      rescue ArgumentError => e
        Logger.error 'load_option_parser: argument error: %s' % [e.message]
        raise ArgumentError, e.message
      rescue Exception => e
        Logger.error 'load_option_parser: unable to generate the parsers, error: %s' % [e.message]
        raise Exception, e.message
      end
    end

    def validate_input(input, argument)
      begin
        # step: we assume all options which do not have an option are boolean
        if argument.class == TrueClass or argument.class == FalseClass
          @options[input.name] = true
          return
        end
        # step: keep a local reference to the original value
        input_option = argument.dup
        # step: perform the input validaton and conversion
        argument = validate_input_regex input, argument if input.validation # check against the regex
        argument = validate_input_proc input, argument if input.validation.proc # check against the proc
        # step: is the input is a attribute of a hash
        argument = parse_attribute_path argument if input.parent
        # step: convert the argument into the format
        value = convert_input_argument argument, input.validation.format # convert the argument to value
        # step: slot into the options
        unless input.parent
          @options[input.name] = value
        else
          @options[input.parent] = {} unless @options[input.parent]
          @cursor = @options[input.parent]
          input_option.split('/').each do |item|
            if item =~ /^(.*)=(.*)$/
              @cursor[$1] = $2
            else
              @cursor[item] = {} unless @cursor[item]
              @cursor = @cursor[item]
            end
          end
        end
      rescue ArgumentError => e
        Logger.error 'validate_input: unable to process the input, error: %s' % [e.message]
        raise ArgumentError, e.message
      rescue Exception => e
        Logger.error 'validate_input: an internal error encounter, %s' % [e.message]
        raise Exception, e.message
      end
    end

    def parse_attribute_path(path)
      value = nil
      path.split('/').each { |x| value = $2 if x =~ /^(.*)=(.*)$/ }
      value
    end

    def convert_input_argument(argument, format)
      return argument if format == :string
      return argument.to_i if format == :integer
      return argument.to_f if format == :float
      return {} if format == :hash
      return [] if format == :array
      nil
    end

    def validate_input_proc(input, argument)
      input.validation.proc.call argument do |success, message|
        raise ArgumentError, 'invalid argument: option: %s, error: %s' % [input.name, message || '']
      end
      argument
    end

    def validate_input_regex(input, argument)
      unless argument =~ input.validation.regex
        raise ArgumentError, "invalid argument: option: '%s', value: '%s', does not match validation: '%s'" % [input.name, argument, input.validation.regex]
      end
      argument
    end

end
end
