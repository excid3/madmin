module Madmin
  module Fields
    class Polymorphic < Field
      def options_for_select(record)
        options.fetch(:collection).call
      end

      def to_param
        { attribute_name => %i{type value} }
      end
    end
  end
end
