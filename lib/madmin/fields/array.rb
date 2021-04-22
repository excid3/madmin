module Madmin
  module Fields
    class Array < Field
      def to_param
        attribute_name => []
      end
    end
  end
end
