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
        destination = Rails.root.join("app/controllers/madmin/#{file_name.pluralize}_controller.rb")
        template("controller.rb", destination)
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
    end
  end
end
