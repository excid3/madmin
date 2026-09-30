module Madmin
  module Fields
    class Currency < Field
      def self.filter_type = :number

      def value(record)
        value = record.public_send(attribute_name)
        value /= 100.0 if value && options.minor_units
        value
      end

      # Filter values are in major units, which minor_units columns don't store
      def filter_type
        super unless options.minor_units
      end

      def searchable?
        options.fetch(:searchable, model.column_names.include?(attribute_name.to_s))
      end
    end
  end
end
