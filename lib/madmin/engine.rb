module Madmin
  class Engine < ::Rails::Engine
    isolate_namespace Madmin

    initializer "madmin.autoload", before: :set_autoload_paths do |app|
      app.config.paths.add "app/madmin/resources", autoload: true
      app.config.paths.add "app/madmin/fields", autoload: true
    end

    initializer "pagy" do |app|
    end
  end
end
