module Madmin
  class Namespace
    def initialize(namespace)
      @namespace = namespace
    end

    def resources
      @resources ||= routes.map(&:first).uniq.map { |path|
        Resource.new(namespace, path)
      }
    end

    def routes
      @routes ||= all_routes.select { |controller, _action|
        controller.starts_with?("#{namespace}/")
      }.map { |controller, action|
        [controller.gsub(/^#{namespace}\//, ""), action]
      }
    end

    def resources_with_index_route
      routes.select { |_resource, route| route == "index" }.map(&:first).uniq
    end

    private

    attr_reader :namespace

    def all_routes
      Rails.application.routes.routes.map do |route|
        route.defaults.values_at(:controller, :action).map(&:to_s)
      end
    end
  end
end
