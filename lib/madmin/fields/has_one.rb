module Madmin
  module Fields
    class HasOne < Field
      def associated_resource_for(object)
        Madmin.resource_for(object)
      rescue MissingResource
      end
    end
  end
end
