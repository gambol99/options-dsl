#
#   Author: Rohith
#   Date: 2014-03-02 13:33:35 +0000 (Sun, 02 Mar 2014)
#
#  vim:ts=4:sw=4:et
#
module OptionsDSL
class Options
    attr_reader :commands, :validations, :options
    def initialize
        @commands    = {}
        @validations = {}
        @options     = {}
    end
    def add_validation v
        raise ArgumentError, "the validation %s already exists, please check the rules" % [ v.name ] if @validations.has_key? v.name
        @validations[v.name] = v
    end
    def add_option option
        @options[option.name] = option
    end
    def add_command command
        @commands[command.name] = command
    end
end
class Command
    attr_accessor :command, :description, :inputs
    def initialize
        @command     = nil
        @description = nil
        @inputs      = {}
        @examples    = {}
    end
end
class Validations
    attr_reader :validations
    def initialize
        @validations = {}
    end
    def validation name, rule
        @validations[name] = rule
    end
    def << validation
        @validation[validation[:name]] = validation
    end 
end
class Validation
    attr_reader :name, :attributes
    def initialize name, attributes
        @name       = name
        @attributes = {}
        @attributes.merge! attributes 
    end
    def has? attribute
        @attributes.has_key? attribute
    end
    def method_missing(m, *args, &block) 
        @attributes[m]
    end
end
class Options
    attr_accessor :name, :short, :long
    def initialize name
        @name  = name
        @short = nil
        @long  = nil
    end
end
class Input
    attr_accessor :name, :attributes
    def initialize name, attributes
        @name       = name
        @attributes = {}
        @attributes.merge! attributes
    end
    def has? attribute
        @attributes.has_key? attribute
    end
    def method_missing(m, *args, &block) 
        @attributes[m] = args.first if !args.empty?
        return @attributes[m] if @attributes.has_key?( m )
        nil
    end
end
class Example
    attr_reader :name, :example
    def initialize name, example
        @name       = name
        @example    = example
    end
end
end