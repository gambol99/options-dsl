#
#   Author: Rohith
#   Date: 2014-03-02 13:33:16 +0000 (Sun, 02 Mar 2014)
#
#  vim:ts=4:sw=4:et
#
$:.unshift File.join(File.dirname(__FILE__),'.','.')
require 'optparse'
require 'model'
require 'utils'
require 'loaders/dsl'
require 'loaders/input'

module OptionsDSL
class Loader

    include Utils

    attr_reader :config, :options, :commands, :validations, :options

    @@default_config = {
        :extention  => '*.ddl',
        :directory  => 'examples/',
        :log_level  => false
    }

    # 
    # method: initialize
    # config: the options for the loader; we need either a filename or a directory,
    #          with extenions specified; 
    # opts:    default options 
    def initialize config = @@default_options, opts = {}
        # step: setup the variable
        @commands    = {}
        @validations = {}
        @options     = {}
        @config      = config 
        @options     = opts
        @parsers     = {}
        # step: lets validate the config
        @config      = validate_config @config
        # step: lets load the command line dsl
        load_options @options
        # step: we need to generate the parser
        load_option_parser @options
        # step: return the options
        @options
    end

    private
    def load_option_parser options = @options
        begin
            @commands.values.each do |c|
                @parsers[name] = OptionsParser::new do |o|
                    o.banner = c.description
                    o.separator ""
                    c.inputs.each_pair do |name,input| 
                        o.on( input.options.short, input.options.long, input.description ) do |x|
                            validate_input x if defined? x
                        end
                    end
                end
            end
        rescue Exception => e 
            Logger.error "load_option_parser: unable to generate the parsers, error: %s" % [ e.message ]
            raise Exception, e.message
        end
    end

    def load_options options = @options
        # step: we iterate each of the options file and load them
        begin 
            @config[:files].each do |filename|
                Logger.debug 'load_options: loading the file: %s' % [ filename ]
                loader = DSLLoader.load filename
                # check: we need to validation the parsed options aginst anything we already have
                loader = validate_options loader, filename
                # step: add the parsed entried into the collected items
            end 
            # step: all the files have been loaded, we do need to perform some post analysis tho and linking
            Logger.debug 'load_options: perform post linking and validation'
            # notes: we need to make sure all the commands options and validations exists and link them for ease
            @commands.values.each do |cmd|
                # step: iterate each of the inputs
                cmd.inputs.values.each do |input|
                    unless @validations[input.validation]
                        raise ArgumentError, "the command: %s has validation: %s, but the validation does not exist" % [ input.name, input.validation ]
                    end
                    input.validation = @validation[input.validation]
                    unless @options[input.options]
                        raise ArgumentError, "the command: %s has options: %s, but the options does not exist" % [ input.name, input.options ]                        
                    end
                    input.options = @options[input.options]
                end
            end
        rescue Exception => e 
            Logger.error 'load_options: unable to load the options dsl, error: %s' % [ e.message ]
            raise Exception, e.message
        end
    end

    def validate_options options, filename 
        Logger.debug 'validate_options: validating the options from file: #{filename}'
        # check: lets make sure the command hasn't been duplicated
        options.commands.values.each do |x|
            raise ArgumentError, "the command: %s has been duplicated in filename: %s" % [ x.name, filename ] if @commands[x.name]
            @commands[c.name] = c 
        end
        # check: lets look for duplcated validations
        options.validations.values.each do |x|
            raise ArgumentError, "the validation: %s has been duplicated in filename: %s" % [ x.name, filename ] if @validations[x.name]
            @validations[x.name] = x 
        end
        # check: lets look for duplcated options
        options.options.values.each do |x|
            raise ArgumentError, "the option: %s has been duplicated in filename: %s" % [ x.name, filename ] if @options[x.name]
            @options[x.name] = x
        end
        Logger.debug 'validate_options: filename: #{filename} successfully passed validation'
        options    
    end

    #
    # method: validate_config
    # description: takes the configutation passed in the initialization and makes sure
    # we have eveything we need to run - i.e. rules files :-)
    #
    def validate_config config = @config
        config[:files] = []
        raise ArgumentError, "you have not defined directory to load the rules from"    unless config[:directory]
        
        config[:directory] = validate_directory config[:directory]
        raise ArgumentError, "directory %s, but not extensions have been specified" % [ config[:directory]  ] unless config[:extensions]
        raise ArgumentError, "the extensions %s does not matched the regex"         % [ config[:extensions] ] unless config[:extensions] =~ /^\*\.[[:alnum:]]+$/
        # check: lets just check we have file in there
        files = Dir.glob( "%s/%s" % [ config[:directory], config[:extensions] ] )
        raise ArgumentError, "the doesn't appear to be any rules in this directory" unless files.size > 0
        config[:files] = files.dup
        config 
    end

    
end
end # end of the module
