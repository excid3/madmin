require "madmin/view_generator"

module Madmin
  module Generators
    class ViewsGenerator < Madmin::ViewGenerator
      def copy_templates
        view = "madmin:views:"
        call_generator("#{view}index", resource_path, "--namespace", namespace)
        call_generator("#{view}show", resource_path, "--namespace", namespace)
        call_generator("#{view}new", resource_path, "--namespace", namespace)
        call_generator("#{view}edit", resource_path, "--namespace", namespace)
      end
    end
  end
end
