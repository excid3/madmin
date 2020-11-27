module Madmin
  module GeneratorHelpers
    def call_generator(generator, *args)
      Rails::Generators.invoke(generator, args, generator_options)
    end

    def route_namespace_exists?
      File.readlines(Rails.root.join("config/routes.rb")).grep(/namespace :madmin/).size > 0
    end

    # Method copied from Rails 6.1 master
    def route(routing_code, namespace: nil, sentinel: nil, indentation: 2)
      routing_code = Array(namespace).reverse.reduce(routing_code) { |code, ns|
        "namespace :#{ns} do\n#{indent(code, 2)}\nend"
      }

      log :route, routing_code
      sentinel ||= /\.routes\.draw do\s*\n/m

      in_root do
        inject_into_file "config/routes.rb", optimize_indentation(routing_code, indentation), after: sentinel, verbose: false, force: false
      end
    end

    # Method copied from Rails 6.1 master
    def optimize_indentation(value, amount = 0)
      return "#{value}\n" unless value.is_a?(String)
      "#{value.strip_heredoc.indent(amount).chomp}\n"
    end

    private

    def generator_options
      {behavior: behavior}
    end
  end
end
