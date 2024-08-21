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

    initializer "madmin.assets" do |app|
      app.config.assets.precompile += %w[madmin_manifest madmin.css]
    end

    initializer "madmin.compile_tailwind_css" do |app|
      # Skip if not running in a Rails server
      next unless defined?(::Rails::Server)

      input_file = Engine.root.join("app/assets/stylesheets/madmin/application.tailwind.css")
      output_file = Engine.root.join("app/assets/builds/madmin.css")
      config_file = Engine.root.join("config/madmin/tailwind.config.js")
      postcss_file = Engine.root.join("config/madmin/postcss.config.js")

      if Rails.env.development?
        Thread.new do
          system("bundle exec tailwindcss -i #{input_file} -o #{output_file} --config #{config_file} --postcss #{postcss_file} --watch")
        end
      end

      if Rails.env.production?
        system("bundle exec tailwindcss -i #{input_file} -o #{output_file} --config #{config_file} --postcss #{postcss_file} --minify")
      end
    end
  end
end
