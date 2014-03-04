#!/usr/bin/ruby
#
#   Author: Rohith
#   Date: 2014-03-04 16:39:37 +0000 (Tue, 04 Mar 2014)
#
#  vim:ts=4:sw=4:et
#
Gem::Specification.new do |s|
    s.name        = 'optionsdsl'
    s.version     = '0.0.1'
    s.date        = '2014-03-04'
    s.summary     = "Command line options dsl"
    s.description = "OptionsDSL provides a ruby dsl for defining, validation and bundling comand line options"
    s.authors     = ["Rohith Jayawardene"]
    s.email       = 'gambol99@gmail.com'
    s.files       = [ "Gemfile", "README.md", "optionsdsl.gemspec", "optionsdsl.rb",
                      "libs/generate/generate.rb", "libs/loaders/dsl.rb", "libs/loaders/input.rb", "tests/test.rb", "examples/example.dsl",
                      "Gemfile", "README.md",  "optionsdsl.gemspec", "optionsdsl.rb" ]
    s.homepage    = 'http://rubygems.org/gems/optionsdsl'
    s.license     = 'MIT'
end
