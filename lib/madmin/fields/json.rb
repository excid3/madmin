module Madmin
  module Fields
    class Json < Field
      def form_value(record)
        value = value(record)
        JSON.pretty_generate(value) unless value.nil?
      end

      def parse(value)
        return value unless value.is_a?(::String)

        value.blank? ? nil : JSON.parse(value)
      rescue JSON::ParserError
        raise InvalidValue
      end
    end
  end
end
