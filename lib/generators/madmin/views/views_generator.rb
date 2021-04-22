require "madmin/view_generator"

module Madmin
  module Generators
    class ViewsGenerator < Madmin::ViewGenerator
      def copy_templates
        # Some generators duplicate templates, so not everything is present here
        call_generator("madmin:views:edit", resource_path, "--namespace", namespace)
        call_generator("madmin:views:index", resource_path, "--namespace", namespace)
        call_generator("madmin:views:layout", resource_path, "--namespace", namespace)
        call_generator("madmin:views:new", resource_path, "--namespace", namespace)
        call_generator("madmin:views:show", resource_path, "--namespace", namespace)
      end
    end
  end
end
