module Quickery
  class Railtie < Rails::Railtie
    # Need to eager load all models so that all quickery callbacks and dependencies will be considered
    config.after_initialize do |app|
      # unless Rails app is already set to eager_load
      unless app.config.eager_load
        models_load_path = File.join(Rails.root, 'app', 'models')

        # copied from https://apidock.com/rails/Rails/Engine/eager_load%21/class
        matcher = /\A#{Regexp.escape(models_load_path.to_s)}\/(.*)\.rb\Z/
        Dir.glob("#{models_load_path}/**/*.rb").sort.each do |file|
          app.require_dependency file.sub(matcher, '\1')
        end
      end
    end
  end
end
