# frozen_string_literal: true

module Madmin
  module Fields
    class Attachment < Field
      # Path for removing the attachment, or nil when it can't be removed.
      # `resource` is the resource that declared this field, so an attachment
      # in a nested form follows the nested resource.
      def remove_path(attachment)
        attachment_resource = Madmin.resource_for(attachment)
        attachment_resource.show_path(attachment) if removable?(attachment_resource)
      rescue MissingResource
      end

      private

      def removable?(attachment_resource)
        !resource.readonly? && !attachment_resource.readonly? && attachment_resource.route?(:destroy)
      end
    end
  end
end
