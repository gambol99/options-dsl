#
#   Author: Rohith
#   Date: 2014-03-02 13:33:16 +0000 (Sun, 02 Mar 2014)
#
#  vim:ts=4:sw=4:et
#
require 'model'

module OptionsDSL
class Loader

    attr_reader :config, :options, :commands, :validations, :options

    @@default_config = {
        :extention  => '*.ddl',
        :directory  => '.',
        :filename   => nil,
        :verbose    => false
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
                loader = OptionsFileLoader.load filename
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


    def validate_config config = @config
        config[:files] = []
        if !config[:filename] and !config[:directory]
            raise ArgumentError, "you have not defined either filename or directory"
        end
        if config[:filename]
            validate_options_file config[:filename]
            config[:files] << @config[:filename]
        else
            config[:directory] = validate_directory config[:directory]
            raise ArgumentError, "directory %s, but not extensions have been specified" % [ config[:directory]  ] unless config[:extensions]
            raise ArgumentError, "the extensions %s does not matched the regex"         % [ config[:extensions] ] unless config[:extensions] =~ /^\*\.[[:alnum:]]+$/
            # check: lets just check we have file in there
            files = Dir.glob( "%s/%s" % [ config[:directory], config[:extensions] ] )
            raise ArgumentError, "the doesn't appear to be any rules in this directory" unless files.size > 0
            config[:files] = files.dup
        end
        # check: not sure how this could happen, but lets check anyhow
        raise ArgumentError, "unable to find any rules to load" unless config[:files].size > 0
        config 
    end

    def validate_directory directory
        raise ArgumentError, "the directory #{directory} does not exist"        unless File.exists? directory
        raise ArgumentError, "the directory #{directory} is not a directory"    unless File.directory? directory
        raise ArgumentError, "the directory #{directory} is not readable"       unless File.readable? directory
        directory
    end

    def validate_options_file filename
        raise ArgumentError, "the filename #{filename} does not exists"         unless File.exists? filename
        raise ArgumentError, "the filename #{filename} is not readable"         unless File.readable? filename
        raise ArgumentError, "the filename #{filename} is not a regular file"   unless File.file? filename
        filename      
    end
end

class OptionsFileLoader

    attr_accessor :options_file

    def initialize 
        @options_file   = nil
        @commands       = {}
        @validations    = {}
        @options        = {}
    end

    def command name, description, &block 
        # check: we need to make sure sure the command doesn't exists already
        raise ArgumentError, "filename: %s, command: %s already exists"         % [ @options_file, name ] if @commands[name] 
        raise ArgumentError, "filename: %s, command: %s does not have a block"  % [ @options_file, name ] unless block_given?
        cmd = Command::new
        cmd.command     = name
        cmd.description = description
        loader = InputLoader.load( block )
        cmd.inputs      = loader.inputs
        cmd.examples    = loader.examples
        @commands[name] = cmd
    end

    def global name, description, &block
        cmd = Command::new
        cmd.command     = :global
        cmd.description = description
        loader = InputLoader.load( block )
        cmd.inputs      = loader.inputs
        cmd.examples    = loader.examples
        @commands[name] = cmd
    end

    def options name, attributes
        opts = Options::new name
        opts.short = attributes[:short]
        opts.long  = attributes[:long]
        @switches << opts
    end

    def validation name, attributes
        valid = Validation::new name, attributes
        @validations << valid
    end

    def self.load filename 
        begin 
            Logger.debug 'load_file: loading the file: %s' % [ filename ]
            input = new
            input.options_file = filename
            input.instance_eval( File.read( filename ), filename )
            input
        rescue Exception => 
            Logger.error 'load_file: error loading file: %s, error: %s' % [ filename, e.message ]
            raise Exception, e.message
        end
    end
end

class InputLoader 
    def initialize 
        @inputs   = {}
        @examples = {}
    end

    def self.load &block
        command = new
        command.instance_eval &block
        command
    end

    def input name, attributes
        # check: the input MUST contain description, options, validation and optional
        [ :description, :optional, :options, :validation ].map do |x|
            raise ArgumentError, "the input: #{name} does not include a ${x} attribute" unless attribute.has_key? x
        end
        # check: check we don't have a duplicate input 
        raise ArgumentError, "the input #{name} is already defined" if @input[name]
        @inputs << Input::new name, attributes
    end

    def example name, text
        @examples << Example::new name, text
    end
end

end # end of the module
