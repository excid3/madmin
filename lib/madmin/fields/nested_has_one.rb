module Madmin
  module Fields
    class NestedHasOne < Field
      DEFAULT_ATTRIBUTES = %w[_destroy id].freeze
      def nested_attributes
        resource.attributes.except(*skipped_fields)
      end

      def resource
        "#{to_model.name}Resource".constantize
      end

      def to_param
        {"#{attribute_name}_attributes": permitted_fields}
      end

      def to_model
        attribute_name.to_s.singularize.classify.constantize
      end

      private

      def permitted_fields
        (resource.permitted_params - skipped_fields + DEFAULT_ATTRIBUTES).uniq
      end

      def skipped_fields
        options[:skip] || []
      end
    end
  end
end
