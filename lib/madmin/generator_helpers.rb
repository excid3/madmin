module Madmin
  module GeneratorHelpers
    ROUTES_FILE = {default: "config/routes.rb", separated: "config/routes/madmin.rb"}.freeze

    def call_generator(generator, *args)
      Rails::Generators.invoke(generator, args, generator_options)
    end

    def route_namespace_exists?
      File.readlines(Rails.root.join(default_routes_file)).grep(/namespace :madmin/).size > 0
    end

    def rails6_1_and_up?
      Gem.loaded_specs["rails"].version >= Gem::Version.new(6.1)
    end

    # Method copied from Rails 6.1 master
    def route(routing_code, namespace: nil, sentinel: nil, indentation: 2, file: default_routes_file)
      routing_code = Array(namespace).reverse.reduce(routing_code) { |code, ns|
        "namespace :#{ns} do\n#{indent(code, 2)}\nend"
      }

      log :route, routing_code
      sentinel ||= default_sentinel(file)

      in_root do
        inject_into_file file, optimize_indentation(routing_code, indentation), after: sentinel, verbose: false, force: false
      end
    end

    # Method copied from Rails 6.1 master
    def optimize_indentation(value, amount = 0)
      return "#{value}\n" unless value.is_a?(String)
      "#{value.strip_heredoc.indent(amount).chomp}\n"
    end

    private

    def separated_routes_file?
      default_routes_file.eql?(ROUTES_FILE[:separated])
    end

    def default_sentinel(file)
      file.eql?(ROUTES_FILE[:default]) ? /\.routes\.draw do\s*\n/m : /namespace :madmin do\s*\n/m
    end

    def default_routes_file
      rails6_1_and_up? ? ROUTES_FILE[:separated] : ROUTES_FILE[:default]
    end

    def generator_options
      {behavior: behavior}
    end
  end
end
