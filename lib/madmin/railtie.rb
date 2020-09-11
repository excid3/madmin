module Madmin
  class Railtie < ::Rails::Railtie
    initializer 'madmin.autoload', before: :set_autoload_paths do |app|
      app.config.paths.add "app/madmin/resources", autoload: true
      app.config.paths.add "app/madmin/fields", autoload: true
    end
  end
end
