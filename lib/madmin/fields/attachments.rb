module Madmin
  module Fields
    class Attachments < Field
      def to_param
        {attribute_name => []}
      end
    end
  end
end
