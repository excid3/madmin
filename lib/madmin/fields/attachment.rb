# frozen_string_literal: true

module Madmin
  module Fields
    class Attachment < Field
      # Path for removing the attachment, or nil when it can't be removed
      def remove_path(attachment)
        attachment_resource = Madmin.resource_for(attachment)
        attachment_resource.show_path(attachment) if attachment_resource.route?(:destroy) && !attachment_resource.readonly_for?(attachment.attachment)
      rescue MissingResource
      end
    end
  end
end
