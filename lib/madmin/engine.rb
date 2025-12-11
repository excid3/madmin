require "importmap-rails"

module Madmin
  class Engine < ::Rails::Engine
    isolate_namespace Madmin

    config.before_configuration do |app|
      app.config.eager_load_paths << app.root.join("app/madmin/resources")
      app.config.eager_load_paths << app.root.join("app/madmin/fields")
      Madmin.resource_locations << Rails.root.join("app/madmin/resources/")

      Rails::Engine.subclasses.each do |engine|
        app.config.eager_load_paths << engine.root.join("app/madmin/resources")
        app.config.eager_load_paths << engine.root.join("app/madmin/fields")
        Madmin.resource_locations << engine.root.join("app/madmin/resources/")
      end
    end

    config.to_prepare do
      Madmin.reset_resources!
      Madmin.site_name ||= Rails.application.class.module_parent_name.titleize
    end

    initializer "madmin.assets" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << root.join("app/assets/stylesheets")
        app.config.assets.paths << root.join("app/javascript")
        app.config.assets.precompile += %w[madmin_manifest]

        Madmin.stylesheets << if defined?(::Sprockets)
          "madmin/application-sprockets"
        else
          "madmin/application"
        end
      end
    end

    initializer "madmin.importmap", before: "importmap" do |app|
      Madmin.importmap.draw root.join("config/importmap.rb")
      Madmin.importmap.cache_sweeper watches: root.join("app/javascript")

      ActiveSupport.on_load(:action_controller_base) do
        before_action { Madmin.importmap.cache_sweeper.execute_if_updated }
      end
    end
  end
end
