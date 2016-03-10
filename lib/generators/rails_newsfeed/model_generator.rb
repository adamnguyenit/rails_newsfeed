require 'rails/generators'
require 'rails_newsfeed/railtie'

module RailsNewsfeed
  class ConfigGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    def create_configuration
      template 'config/cassandra.yml'
    end
  end
end
