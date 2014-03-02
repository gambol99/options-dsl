#
# Author: Rohith 
# Date:   2014-03-02 14:59:43
# Last Modified by:   Rohith
#
# vim:ts=4:sw=4:et
require 'logger'

module OptionsDSL
class Logger
    class << self
        attr_accessor :logger

        # :level => :debug
        # :std => out|err|file-name
        def init( options )
            self.logger = ::Logger.new(options[:std] || STDOUT)
            self.logger.level= ::Logger.const_get "#{options[:level].to_s.upcase}"
        end

        def method_missing(m,*args,&block)
            logger.send m, *args, &block if logger.respond_to? m
        end
    end
end
end