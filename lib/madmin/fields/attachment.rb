# frozen_string_literal: true

module Madmin
  module Fields
    class Attachment < Field
      # Path for removing the attachment, or nil when it can't be removed
      def remove_path(attachment)
        attachment_resource = Madmin.resource_for(attachment)
        attachment_resource.show_path(attachment) if removable?(attachment, attachment_resource)
      rescue MissingResource
      end

      private

      # Mirrors ResourceController#enforce_readonly: removal is refused when the
      # attachment's resource or the attached record's resource is read-only
      def removable?(attachment, attachment_resource)
        attachment_resource.route?(:destroy) && !attachment_resource.readonly? && !record_resource(attachment)&.readonly?
      end

      def record_resource(attachment)
        Madmin.resource_for(attachment.record)
      rescue MissingResource
      end
    end
  end
end
