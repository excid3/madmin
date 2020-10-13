module Madmin
  module Fields
    class Polymorphic < Field
      def options_for_select(record)
        if (collection = options[:collection])
          collection.call
        else
          []
        end
      end

      def to_param
        {attribute_name => %i[type value]}
      end
    end
  end
end
