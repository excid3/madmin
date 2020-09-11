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

      private

      def associations
        model.reflections.keys
      end

      def attributes
        model.attribute_names - redundant_attributes
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
