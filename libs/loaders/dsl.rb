#
#
# Author: Rohith 
# Date:   2014-03-02 17:16:49
# Last Modified by:   Rohith
#
# vim:ts=4:sw=4:et
#
module OptionsDSL
class DSLLoader

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
        cmd             = Command::new
        cmd.command     = name
        cmd.description = description
        loader          = InputLoader.load( block )
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
end