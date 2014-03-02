#!/usr/bin/ruby
#
#   Author: Rohith
#   Date: 2014-03-02 13:29:33 +0000 (Sun, 02 Mar 2014)
#
#  vim:ts=4:sw=4:et
#
module OptionsDSL
    ROOT = File.expand_path File.dirname __FILE__

    autoload :Version,  "#{ROOT}/libs/version"
    autoload :Loader,   "#{ROOT}/lobs/loader"  
    autoload :Logger,   "#{ROOT}/lobs/logger"

    def self.version
        OptionsDSL::VERSION
    end 

    def self.load filename, options = {}
        OptionsDSL::new filename, options
    end
end