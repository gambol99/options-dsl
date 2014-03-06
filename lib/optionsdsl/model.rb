#
#   Author: Rohith
#   Date: 2014-03-02 13:33:35 +0000 (Sun, 02 Mar 2014)
#
#  vim:ts=4:sw=4:et
#
module OptionsDSL
class Rules
    attr_accessor :commands, :validations, :options
    attr_reader   :parser
    def initialize
        @commands    = {}
        @validations = {}
        @options     = {}
        @parser      = {}
    end
    def validation? name
        @validations.has_key? name
    end
    def command? name
        @commands.has_key name
    end
    def option? name
        @options.has_key? name
    end
end
class Command
    attr_reader :name, :description, :usage
    attr_accessor :inputs, :examples
    def initialize name, description
        @name        = name
        @description = description
        @inputs      = {}
        @examples    = nil
        @usage       = nil
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
        @attributes[m] = args.first unless args.empty?
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