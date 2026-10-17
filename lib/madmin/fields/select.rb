# frozen_string_literal: true

module Madmin
  module Fields
    class Select < Field
      def options_for_select(record)
        options.collection
      end
    end
  end
end
