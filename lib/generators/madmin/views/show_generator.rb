require "madmin/view_generator"

module Madmin
  module Generators
    module Views
      class ShowGenerator < Madmin::ViewGenerator
        source_root template_source_path

        def copy_template
          copy_resource_template("show")
        end
      end
    end
  end
end
