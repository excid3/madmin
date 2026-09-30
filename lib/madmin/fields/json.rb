module Madmin
  module Fields
    class Json < Field
      # Text that isn't JSON is shown as it is, so it can be corrected in the form
      def json(record)
        value = value(record)

        if value.nil? || value.is_a?(::String)
          value
        else
          JSON.pretty_generate(value)
        end
      end

      def cast(value)
        JSON.parse(value) if value.present?
      rescue JSON::ParserError
        value
      end

      # Still being text after the cast means it could not be parsed
      def accepts?(value)
        !value.is_a?(::String)
      end
    end
  end
end
