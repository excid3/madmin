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

        # has_secure_password columns
        password_attributes = model.attribute_types.keys.select { |k| k.ends_with?("_digest") }.map { |k| k.delete_suffix("_digest") }
        virtual += password_attributes.map { |attr| [attr, "#{attr}_confirmation"] }.flatten

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

        # has_secure_password columns
        redundant += model.attribute_types.keys.select { |k| k.ends_with?("_digest") }

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
        elsif !model.column_names.include?(name)
          {index: false}
        end
      end
    end
  end
end
