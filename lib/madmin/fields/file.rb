# frozen_string_literal: true

module Madmin
  module Fields
    class File < Field
      def searchable?
        false
      end
    end
  end
end
