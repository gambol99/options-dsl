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

    def initialize rules, options = {}
        @rules   = rules
        @parser  = parsers rules 
        @options = options
        @cursor  = @options
    end

    def parse! arguments = ARGV
        # step: we need to group the command into batches and process via the respective parser
        batches = process_batches arguments
        begin 
            batches.each_pair do |command,options|
                @rules.parser[command].parse! options
            end
        rescue ArgumentError => e 
            Logger.error "parse! argument error: %s" % [ e.message ]
            raise ArgumentError, e.message
        end
        @options
    end

    private
    # description: the method carves up the command line options into the respective processors
    def process_batches arguments 
        batches = @rules.commands.keys.inject({}) { |h,arg| h.merge( arg => [] ) }
        cursor  = batches[:global]
        arguments.map do |x|
            if batches.include? x.to_sym
                cursor = batches[x.to_sym]
            else
                cursor << x
            end
        end
        batches
    end

    # method: takes the dsl structure and generates the parsers from it
    def parsers rules = @rules
        @parser = {}
        begin
            if rules.commands.has_key? :global
                global = rules.commands[:global]
                rules.parser[:global] = ::OptionParser::new do |o|
                    o.banner = "script [global options] [subcommand] [options]" 
                    o.separator ""
                    o.separator "\tGlobal Options:"
                    o.separator "\t==============="
                    o.separator ""
                    global.inputs.each_pair do |name,input|
                        o.on( input.options.short, input.options.long, input.description ) do |x|
                            validate_input input, x
                        end
                    end
                    if rules.commands.size > 1 
                        o.separator ""
                        o.separator "\tSubcommands: script subcommand [options]"
                        o.separator "\t========================================"
                        o.separator ""
                    end
                    o.on( "-h", "--help",   "display the help usage menu" ) do
                        puts rules.parser[:global]
                        rules.commands.each_pair do |name,command|
                            next if command.name == :global
                            puts rules.parser[command.name]
                        end
                    end
                end
            end
            rules.commands.values.each do |c|
                next if c.name == :global
                rules.parser[c.name] = ::OptionParser::new do |o|
                    o.banner = ''
                    o.separator "\tcommand: [%s]:    %s\n"           % [ c.name, c.description ]
                    o.separator ""
                    c.inputs.each_pair do |name,input|
                        o.on( input.options.short, input.options.long, input.description ) do |x|
                            validate_input input, x if defined? x
                        end
                    end
                end
            end
        rescue Exception => e 
            Logger.error "load_option_parser: unable to generate the parsers, error: %s" % [ e.message ]
            raise Exception, e.message
        end
    end

    def validate_input input, argument
        begin
            # step: we assume all options which do not have an option are boolean
            if argument == nil
                @options[input.name] = true
                return
            end
            # step: keep a local reference to the original value
            input_option = argument.dup
            # step: perform the input validaton and conversion
            argument = validate_input_regex input, argument if input.validation         # check against the regex
            argument = validate_input_proc  input, argument if input.validation.proc    # check against the proc
            # step: is the input is a attribute of a hash
            argument = parse_attribute_path argument if input.parent 
            # step: convert the argument into the format
            value = convert_input_argument argument, input.validation.format            # convert the argument to value
            # step: slot into the options
            if !input.parent
                @options[input.name]   = value
            else
                @options[input.parent] = {} unless @options[input.parent]
                @cursor                = @options[input.parent]
                input_option.split('/').each do |item|
                    if item =~ /^(.*)=(.*)$/
                        @cursor[$1]   = $2
                    else
                        @cursor[item] = {} unless @cursor[item]
                        @cursor       = @cursor[item]
                    end
                end
            end
        rescue Exception => e 
            Logger.error 'validate_input: unable to process the input, error: %s' % [ e.message ]
            raise Exception, e.message
        end
    end

    def parse_attribute_path path
        value = nil
        path.split('/').each { |x| value = $2 if x =~ /^(.*)=(.*)$/ } 
        value
    end

    def convert_input_argument argument, format
        return argument         if format == :string
        return argument.to_i    if format == :integer
        return argument.to_f    if format == :float
        return {}               if format == :hash
        return []               if format == :array
        nil
    end

    def validate_input_proc input, argument
        input.validation.proc.call argument do |success,message|
            raise ArgumentError, 'invalid argument: option: %s, error: %s' % [ input.name, message || '' ]    
        end   
        argument
    end

    def validate_input_regex input, argument
        unless argument =~ input.validation.regex
            raise ArgumentError, "invalid argument: the option: '%s' does not match validation: %s" % [ input.name, input.validation.regex ] 
        end
        argument
    end


end
end