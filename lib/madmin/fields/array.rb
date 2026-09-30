module Madmin
  module Fields
    # PostgreSQL array columns, shown and edited as comma separated values
    class Array < Field
      def self.filter_type = :array

      def text(record)
        value(record)&.join(", ")
      end

      def cast(value)
        value.to_s.split(",").map(&:strip).compact_blank
      end
    end
  end
end
