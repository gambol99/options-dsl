#!/usr/bin/ruby
#
#   Author: Rohith
#   Date: 2014-03-04 16:39:37 +0000 (Tue, 04 Mar 2014)
#
#  vim:ts=4:sw=4:et
#
$:.unshift File.join(File.dirname(__FILE__),'.','lib/optionsdsl' )
require 'version'

Gem::Specification.new do |s|
    s.name        = "optionsdsl"
    s.version     = OptionsDSL::VERSION
    s.platform    = Gem::Platform::RUBY
    s.date        = '2014-03-04'
    s.authors     = ["Rohith Jayawardene"]
    s.email       = 'gambol99@gmail.com'
    s.homepage    = 'http://rubygems.org/gems/optionsdsl'
    s.summary     = %q{Command line options dsl}
    s.description = %q{OptionsDSL provides a ruby dsl for defining, validation and bundling comand line options.}
    s.license     = 'MIT'

    s.add_dependency 'sinatra'

    s.files         = `git ls-files`.split("\n")
    s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
    s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
    s.require_paths = ["lib"]
end
