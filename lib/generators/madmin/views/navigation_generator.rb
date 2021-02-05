require "madmin/view_generator"

module Madmin
  module Generators
    module Views
      class NavigationGenerator < Madmin::ViewGenerator
        source_root template_source_path

        def copy_navigation
          copy_resource_template("_navigation")
        end
      end
    end
  end
end
