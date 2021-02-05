require "madmin/view_generator"

module Madmin
  module Generators
    module Views
      class LayoutGenerator < Madmin::ViewGenerator
        source_root template_source_path

        def copy_template
          copy_file(
            "../../layouts/madmin/application.html.erb",
            "app/views/layouts/madmin/application.html.erb"
          )

          call_generator("madmin:views:navigation")
          copy_resource_template("_javascript")
        end
      end
    end
  end
end
