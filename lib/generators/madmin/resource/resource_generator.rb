module Madmin
  module Generators
    class ResourceGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("../templates", __FILE__)

      def eager_load
        Rails.application.eager_load!
      end

      def generate_resource
        template "resource.rb", "app/madmin/resources/#{file_path}_resource.rb"
      end

      def generate_controller
        destination = Rails.root.join("app/controllers/madmin/#{file_path.pluralize}_controller.rb")
        template("controller.rb", destination)
      end

      def generate_route
        if route_namespace_exists?
          route "resources :#{plural_name}", namespace: class_path, indentation: 4, sentinel: /namespace :madmin do\s*\n/m
        else
          route "resources :#{plural_name}", namespace: [:madmin] + class_path
        end
      end

      private

      def associations
        model.reflections.reject { |name, association|
          # Hide these special associations
          name.starts_with?("rich_text") ||
            name.ends_with?("_attachment") ||
            name.ends_with?("_attachments") ||
            name.ends_with?("_blob") ||
            name.ends_with?("_blobs")
        }.keys
      end

      def attributes
        model.attribute_names + virtual_attributes - redundant_attributes
      end

      def virtual_attributes
        virtual = []

        # Add virtual attributes for ActionText and ActiveStorage
        model.reflections.each do |name, association|
          if name.starts_with?("rich_text")
            virtual << name.split("rich_text_").last
          elsif name.ends_with?("_attachment")
            virtual << name.split("_attachment").first
          elsif name.ends_with?("_attachments")
            virtual << name.split("_attachments").first
          end
        end

        virtual
      end

      def redundant_attributes
        redundant = []

        model.reflections.each do |name, association|
          if association.has_one?
            next
          elsif association.collection?
            next
          elsif association.polymorphic?
            redundant << "#{name}_id"
            redundant << "#{name}_type"
          elsif name.starts_with?("rich_text")
            redundant << name
          else # belongs to
            redundant << "#{name}_id"
          end
        end

        redundant
      end

      def model
        @model ||= class_name.constantize
      end

      def route_namespace_exists?
        File.readlines(Rails.root.join("config/routes.rb")).grep(/namespace :madmin/).size > 0
      end

      # Method copied from Rails 6.1 master
      def route(routing_code, namespace: nil, sentinel: nil, indentation: 2)
        routing_code = Array(namespace).reverse.reduce(routing_code) do |code, ns|
          "namespace :#{ns} do\n#{indent(code, 2)}\nend"
        end

        log :route, routing_code
        sentinel ||= /\.routes\.draw do\s*\n/m

        in_root do
          inject_into_file "config/routes.rb", optimize_indentation(routing_code, indentation), after: sentinel, verbose: false, force: false
        end
      end

      # Method copied from Rails 6.1 master
      def optimize_indentation(value, amount = 0) # :doc:
        return "#{value}\n" unless value.is_a?(String)
        "#{value.strip_heredoc.indent(amount).chomp}\n"
      end
    end
  end
end
