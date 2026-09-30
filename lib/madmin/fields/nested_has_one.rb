module Madmin
  module Fields
    class NestedHasOne < HasOne
      DEFAULT_ATTRIBUTES = %w[_destroy id].freeze

      def nested_attributes
        resource.attributes.except(*skipped_fields)
      end

      def resource
        Madmin.resource_by_name(to_model)
      end

      def to_param
        {"#{attribute_name}_attributes": permitted_fields}
      end

      # Index and show link to the record like a has_one, and the form shares
      # its fields with nested_has_many
      def to_partial_path(name)
        case name.to_s
        when "index", "show"
          "/madmin/fields/has_one/#{name}"
        when "form"
          "/madmin/fields/nested_has_one/form"
        when "fields"
          "/madmin/fields/nested_has_many/fields"
        else
          raise ArgumentError, "`partial` must be 'index', 'show', 'form' or 'fields'"
        end
      end

      def to_model
        model.reflect_on_association(attribute_name).klass
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
