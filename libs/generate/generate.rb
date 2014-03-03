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
        @parser  = parsers rules 
        @options = options
        @cursor  = @options
    end

    private
    def parsers rules = @rules
        begin
            rules.commands.values.each do |c|
                rules.parser[c.name] = ::OptionParser::new do |o|
                    o.banner = ''
                    o.separator "\tCommand: %s\n"      % [ c.name  ]
                    o.separator "\tUsage: %s\n"        % [ c.usage ] if c.usage
                    o.separator "\tDescription: %s\n"  % [ c.description ]
                    o.separator ""
                    c.inputs.each_pair do |name,input|
                        o.on( input.options.short, input.options.long, input.description ) do |x|
                            validate_input input, x if defined? x
                        end
                    end
                end
                puts rules.parser[c.name]
            end
        rescue Exception => e 
            Logger.error "load_option_parser: unable to generate the parsers, error: %s" % [ e.message ]
            raise Exception, e.message
        end
    end

    def validate_input input, argument
        begin
            return if argument == nil
            # step: lets validate the input against the validation regex
            unless argument =~ input.validation.regex
                raise ArgumentError, "invalid argument: the option: '%s' does not match validation: %s" % [ input.name, input.validation ]
            end
            # step: if the validation has a proc, lets call it
            if input.validation.proc
                input.validation.proc.call argument
            end
            # step: we are good like perform any conversions required
            case input.validation.format
            when :integer
                @options[input.name] = argument.to_i
            when :float
                @options[input.name] = argument.to_f
            when :hash
                @options[input.name] = {}
                @options[input.name] = {
                    argument.to_sym => {}
                }
                @cursor[@options[input.name]]
            when :attribute
                Logger.debug 'validate_input: the attribute cusror has not been set'                    unless @cursor
                raise ArgumentError, 'you need to specify a parent before you can assign an attribute'  unless @cursor
                arg.split('/').each do |item|
                    if argument =~ /^(.*)=(.*)$/
                        @cursor[$1] = $2
                    else
                        @cursor[item] = {}
                    end
                end
            end
        rescue Exception => e 
            Logger.error 'validate_input: unable to process the input, error: %s' % [ e.message ]
            raise Exception, e.message
        end
    end

end
end