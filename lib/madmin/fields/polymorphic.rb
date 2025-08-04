module Madmin
  module Fields
    class Polymorphic < Field
      def options_for_select(record)
        if (collection = options[:collection])
          collection.call
        else
          [value(record)].compact
        end
      end

      def to_param
        {attribute_name => %i[type value]}
      end

      def associated_resource_for(object)
        Madmin.resource_for(object)
      rescue MissingResource
      end
    end
  end
end
