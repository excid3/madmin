module Madmin
  module Fields
    class Currency < Field
      def value(record)
        value = record.public_send(attribute_name)
        value /= 100.0 if value && options.minor_units
        value
      end

      def searchable?
        options.fetch(:searchable, model.column_names.include?(attribute_name.to_s))
      end
    end
  end
end
