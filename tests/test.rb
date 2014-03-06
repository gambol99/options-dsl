#!/usr/bin/ruby
#
#   Author: Rohith
#   Date: 2014-03-04 10:10:24 +0000 (Tue, 04 Mar 2014)
#
#  vim:ts=4:sw=4:et
#
$:.unshift File.join(File.dirname(__FILE__),'.','../lib')
require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'optionsdsl'
require 'pp'

config = {
    :directory  => '../examples',
    :extensions => '*.dsl'
}
    
options    = {}
start_time = Time.now 
cli        = nil
begin  
    cli        = OptionsDSL.load config, options 
    options    = cli.parse!
    time_taken = ( Time.now - start_time ) * 1000
    puts ""
    puts "Options Generated: (processed time: %d ms)" % [ time_taken ]
    PP.pp options
rescue ArgumentError => e 
	puts e.message
	cli.usage e.message
end

