module Madmin
  class Engine < ::Rails::Engine
    isolate_namespace Madmin

    initializer "madmin.autoload", before: :set_autoload_paths do |app|
      app.config.paths.add "app/madmin/resources", eager_load: true
      app.config.paths.add "app/madmin/fields", eager_load: true
    end

    initializer "pagy" do |app|
    end

    config.to_prepare do
      Madmin.resources = []
    end
  end
end
