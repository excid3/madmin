# frozen_string_literal: true

module Madmin
  module Fields
    class Attachment < Field
      # Path for removing the attachment, or nil when the attachment resource
      # or its destroy route has been removed from the app, or when either
      # resource is read-only
      def remove_path(attachment)
        return if resource.readonly?

        attachment_resource = Madmin.resource_for(attachment)
        attachment_resource.show_path(attachment) if attachment_resource.route?(:destroy) && !attachment_resource.readonly?
      rescue MissingResource
      end
    end
  end
end
