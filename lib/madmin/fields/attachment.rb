module Madmin
  module Fields
    class Attachment < Field
      # Path for removing the attachment, or nil when the attachment resource
      # or its destroy route has been removed from the app
      def remove_path(attachment)
        resource = Madmin.resource_for(attachment)
        resource.show_path(attachment) if resource.route?(:destroy)
      rescue MissingResource
      end
    end
  end
end
