#!/usr/bin/ruby
#
#   Author: Rohith
#   Date: 2014-03-02 13:29:33 +0000 (Sun, 02 Mar 2014)
#
#  vim:ts=4:sw=4:et
#
module OptionsDSL
    ROOT = File.expand_path File.dirname __FILE__

    autoload :Version,  "#{ROOT}/optionsdsl/version"
    autoload :Logger,   "#{ROOT}/optionsdsl/logger"
    autoload :Loader,   "#{ROOT}/optionsdsl/loader"  

    def self.version
        OptionsDSL::VERSION
    end 

    def self.load config, options = {}
        OptionsDSL::Loader::new config, options
    end
end
