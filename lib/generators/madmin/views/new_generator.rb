require "madmin/view_generator"

module Madmin
  module Generators
    module Views
      class NewGenerator < Madmin::ViewGenerator
        source_root template_source_path

        def copy_new
          copy_resource_template("new")
          copy_resource_template("_form")
        end
      end
    end
  end
end
