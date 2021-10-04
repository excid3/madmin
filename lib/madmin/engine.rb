module Madmin
  class Engine < ::Rails::Engine
    config.before_configuration do |app|
      app.config.autoload_paths << File.expand_path("app/madmin/resources", Rails.root)
      app.config.autoload_paths << File.expand_path("app/madmin/fields", Rails.root)
      app.config.assets.precompile << "madmin_manifest.js"
    end

    config.to_prepare do
      Madmin.reset_resources!
    end
  end
end
