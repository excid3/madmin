module Madmin
  module Fields
    class NestedHasMany < Field
      DEFAULT_ATTRIBUTES = %w[_destroy id].freeze
      def nested_attributes
        resource.attributes.reject { |i| skipped_fields.include?(i[:name]) }
      end

      def resource
        "#{to_model.name}Resource".constantize
      end

      def to_param
        {"#{attribute_name}_attributes": permitted_fields}
      end

      def to_partial_path(name)
        unless %w[index show form fields].include? name
          raise ArgumentError, "`partial` must be 'index', 'show', 'form' or 'fields'"
        end

        "/madmin/fields/#{self.class.field_type}/#{name}"
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
