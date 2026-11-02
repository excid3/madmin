# frozen_string_literal: true

module Madmin
  module Fields
    class Attachment < Field
      # Path for removing the attachment, or nil when it can't be removed
      def remove_path(attached)
        attachment_resource = Madmin.resource_for(attached)

        if attachment_resource.route?(:destroy) && !attachment_resource.readonly_for?(attached.attachment)
          attachment_resource.show_path(attached)
        end
      rescue MissingResource
      end
    end
  end
end
