# frozen_string_literal: true

module Madmin
  module Fields
    class NestedHasMany < HasMany
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

      def to_partial_path(name)
        unless %w[index show form fields].include? name
          raise ArgumentError, "`partial` must be 'index', 'show', 'form' or 'fields'"
        end

        "/madmin/fields/#{self.class.field_type}/#{name}"
      end

      def to_model
        model.reflect_on_association(attribute_name).klass
      end

      def paginateable?
        true
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
