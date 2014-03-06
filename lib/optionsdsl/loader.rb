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
require 'generate/generate'

module OptionsDSL
class Loader

    include Utils

    # 
    # method: initialize
    # config: the options for the loader; we need either a filename or a directory with extenions specified; 
    # 
    def initialize config, options
        # step: setup the variable
        @options     = options
        @rules       = OptionsDSL::Rules::new
        @config      = config 
        # step: lets validate the config
        @config      = validate_config @config
        # step: lets load the command line dsl
        load_options
        # step: we need to generate the parser
        @generate    = OptionsDSL::Generate::new @rules, @options
        # step: return the options
    end

    def usage message
        puts @rules.parser[:global]
        @rules.parser.each_pair do |name,parser|
            next if name == :global
            puts parser
        end
        if message
            puts "\n[Error]: #{message}"
            exit 1
        end
        exit 0
    end

    def parse!
        begin
            Logger.debug 'parse!: parsing the command line options' 
            @generate.parse!
        rescue ArgumentError => e 
            raise ArgumentError, e.message
        rescue SystemExit => e 
            raise SystemExit
        rescue Exception  => e 
            Logger.error 'parse!: error parsing the command line options, error: %s' % [ e.message ]
            raise Exception, e.message
        end
        @options
    end

    private
    #
    # method: load_options
    # description: the method iterates the rules files and loads the dsl strcuture. Post loading the rules
    # are then parsed again to validate the options and validations exist and link them into the inputs
    #
    def load_options
        # step: we iterate each of the options file and load them
        begin 
            @config[:files].each do |filename|
                Logger.info 'load_options: loading the file: %s' % [ filename ]
                loader = DSLLoader.load filename
                # check: we need to validation the parsed options aginst anything we already have
                loader = validate_rules loader, filename
                # step: add the parsed entried into the collected items
            end
            # step: all the files have been loaded, we do need to perform some post analysis tho and linking
            Logger.debug 'load_options: perform post linking and validation'
            # notes: we need to make sure all the commands options and validations exists and link them for ease
            @rules.commands.each_pair do |name,command|
                Logger.debug 'load_options: processing the command: #{name}'
                # step: iterate each of the inputs
                command.inputs.each_pair do |input_name,input|
                    ## Validations ===
                    unless @rules.validation? input.validation
                        raise ArgumentError, "command: '%s' has validation: '%s' but the validation does not exist" % [ input_name, input.validation ]
                    end
                    # step: lets link the validation into the input
                    input.validation @rules.validations[input.validation]
                    ## Options ===
                    unless @rules.option? input.options
                        raise ArgumentError, "command: '%s' has options: '%s' but the options does not exist" % [ input_name, input.options ]                        
                    end
                    input.options @rules.options[input.options]
                end
            end
        rescue Exception => e 
            Logger.error 'load_options: unable to load the options dsl, error: %s' % [ e.message ]
            raise Exception, e.message
        end
    end

    #
    # method: validate_rules
    # description: once a dsl file has been loaded we double check the structure to ensure we have
    # no duplicates 
    #
    def validate_rules loader, filename 
        Logger.debug 'validate_rules: validating the options from file: #{filename}'
        # check: lets make sure the command hasn't been duplicated
        loader.commands.values.each do |x|
            raise ArgumentError, "the command: %s has been duplicated in filename: %s" % [ x.name, filename ] if @rules.commands[x.name]
            @rules.commands[x.name] = x 
        end
        # check: lets look for duplcated validations
        loader.validations.values.each do |x|
            raise ArgumentError, "the validation: %s has been duplicated in filename: %s" % [ x.name, filename ] if @rules.validations[x.name]
            @rules.validations[x.name] = x 
        end
        # check: lets look for duplcated options
        loader.options.values.each do |x|
            raise ArgumentError, "the option: %s has been duplicated in filename: %s" % [ x.name, filename ] if @rules.options[x.name]
            @rules.options[x.name] = x
        end
        Logger.debug 'validate_rules: filename: #{filename} successfully passed validation'
        loader    
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
