require 'rails/generators'
require 'rails_newsfeed/railtie'

module RailsNewsfeed
  class ConfigGenerator < Rails::Generators::Base
    desc 'This generator creates the config/cassandra.xml file to config cassandra server for newsfeed'
    source_root File.expand_path('../templates', __FILE__)
    def process
      template 'config/cassandra.yml'
    end
  end
end
