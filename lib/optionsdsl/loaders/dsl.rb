#
# Author: Rohith 
# Date:   2014-03-02 17:16:49
# Last Modified by:   Rohith
#
# vim:ts=4:sw=4:et
#
module OptionsDSL
class DSLLoader

    attr_reader   :commands, :validations, :options
    attr_accessor :options_file

    def initialize 
        @options_file   = nil
        @commands       = {}
        @validations    = {}
        @options        = {}
    end

    def command(name, description, &block)
      # check: we need to make sure sure the command doesn't exists already
      raise ArgumentError, 'filename: %s, command: %s already exists' % [@options_file, name] if @commands[name]
      raise ArgumentError, 'filename: %s, command: %s does not have a block' % [@options_file, name] unless block_given?
      cmd = Command::new name, description
      loader = InputLoader.load(&block)
      cmd.inputs = loader.inputs
      cmd.examples = loader.usages
      @commands[name] = cmd
    end
    
    def option(name, attributes)
      opts = Options::new name
      opts.short = attributes[:short]
      opts.long = attributes[:long]
      @options[name] = opts
    end

    def validation(name, attributes)
      valid = Validation::new name, attributes
      @validations[name] = valid
    end

    def self.load(filename)
      begin
        Logger.debug 'load_file: loading the file: %s' % [filename]
        dsl = new
        dsl.options_file = filename
        dsl.instance_eval(File.read(filename), filename)
        dsl
      rescue Exception => e
        Logger.error 'load_file: error loading file: %s, error: %s' % [filename, e.message]
        raise Exception, e.message
      end
    end
end
end
