module Madmin
  module Fields
    class Enum < Field
      def options_for_select(record)
        model.defined_enums[attribute_name.to_s].keys
      end
    end
  end
end
