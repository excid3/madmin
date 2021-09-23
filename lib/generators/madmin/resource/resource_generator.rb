module Madmin
  module Generators
    class ResourceGenerator < Rails::Generators::NamedBase
      include Madmin::GeneratorHelpers

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
          route "resources :#{plural_name}", namespace: class_path, indentation: separated_routes_file? ? 2 : 4, sentinel: /namespace :madmin do\s*\n/m
        else
          route "resources :#{plural_name}", namespace: [:madmin] + class_path
        end
      end

      private

      def model
        @model ||= class_name.constantize
      end

      def resource_builder
        @resource_builder ||= ResourceBuilder.new(model)
      end

      def model_attributes
        resource_builder.attributes
      end

      delegate :associations, :virtual_attributes, :store_accessors, to: :resource_builder

      def formatted_options_for_attribute(name)
        options = options_for_attribute(name)
        return if options.blank?

        ", " + options.map { |key, value|
          "#{key}: #{value}"
        }.join(", ")
      end

      def options_for_attribute(name)
        if %w[id created_at updated_at].include?(name)
          {form: false}

        # has_secure_passwords should only show on forms
        elsif name.ends_with?("_confirmation") || virtual_attributes.include?("#{name}_confirmation")
          {index: false, show: false}

        # Counter cache columns are typically not editable
        elsif name.ends_with?("_count")
          {form: false}

        # Attributes without a database column
        elsif !model.column_names.include?(name) && !store_accessors.map(&:to_s).include?(name)
          {index: false}
        end
      end
    end
  end
end
