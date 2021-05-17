module Madmin
  class Engine < ::Rails::Engine
    initializer "madmin.autoload", before: :set_autoload_paths do |app|
      app.config.paths.add "app/madmin/resources", eager_load: true
      app.config.paths.add "app/madmin/fields", eager_load: true
    end

    config.to_prepare do
      Madmin.reset_resources!
    end
  end
end
