module Madmin
  module Fields
    class NestedHasMany < Field
      def nested_attributes
        resource.attributes.reject { |i| skipped_fields.include?(i[:name]) }
      end

      def resource
        "#{attribute_name.to_s.singularize.camelize}Resource".constantize
      end

      def to_param
        {"#{attribute_name}_attributes": permitted_fields}
      end

      private
      def permitted_fields
        resource.permitted_params - skipped_fields
      end

      def skipped_fields
        options[:skip] || []
      end
    end
  end
end
