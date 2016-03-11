# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails_newsfeed/version'

Gem::Specification.new do |spec|
  spec.name = 'rails_newsfeed'
  spec.version = RailsNewsfeed::VERSION
  spec.authors = ['Adam Nguyen']
  spec.email = ['adamnguyen.itdn@gmail.com']
  spec.summary = 'News Feed module for ruby'
  spec.description = 'News Feed module for ruby'
  spec.homepage = 'https://github.com/adamnguyenit/rails_newsfeed'
  spec.license = 'MIT'
  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.0'
  spec.add_dependency 'rails', '>= 4.0.0'
  spec.add_dependency 'cassandra-driver', '~> 3.0.0.rc.1'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
end
