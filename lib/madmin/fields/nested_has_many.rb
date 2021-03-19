module Madmin
  module Fields
    class NestedHasMany < Field

      def nested_attributes
        resource.attributes.select{|i| allowed_params.include?(i[:name]) }
      end

      def resource
        "#{attribute_name.to_s.singularize.camelize}Resource".constantize
      end

      def to_param
        { "#{attribute_name}_attributes": allowed_params }
      end

      def allowed_params
        options[:allowed_attributes]
      end
    end
  end
end
