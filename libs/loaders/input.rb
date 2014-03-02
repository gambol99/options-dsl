#!/usr/bin/ruby
#
# Author: Rohith 
# Date:   2014-03-02 17:17:28
# Last Modified by:   Rohith
#
# vim:ts=4:sw=4:et
#
module OptionsDSL
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
end