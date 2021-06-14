module Madmin
  module Fields
    class String < Field
      def searchable?
        options.fetch(:searchable, model.column_names.include?(attribute_name.to_s))
      end
    end
  end
end
