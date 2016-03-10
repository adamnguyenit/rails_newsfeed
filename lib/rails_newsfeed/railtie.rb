module RailsNewsfeed
  class Railtie < Rails::Railtie
    def self.app_name
      Rails.application.railtie_name.sub(/_application$/, '')
    end
  end
end
