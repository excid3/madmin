module Madmin
  module Fields
    class Text < Field
      def searchable?
        options.fetch(:searchable, resource.model_column_names.include?(attribute_name.to_s))
      end
    end
  end
end
