module Madmin
  class Engine < ::Rails::Engine
    isolate_namespace Madmin

    config.before_configuration do |app|
      app.config.eager_load_paths << File.expand_path("app/madmin/resources", Rails.root)
      app.config.eager_load_paths << File.expand_path("app/madmin/fields", Rails.root)
    end

    config.to_prepare do
      Madmin.reset_resources!
    end
  end
end
