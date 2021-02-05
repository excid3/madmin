require "madmin/view_generator"

module Madmin
  module Generators
    module Views
      class FormGenerator < Madmin::ViewGenerator
        source_root template_source_path

        def copy_form
          copy_resource_template("_form")
        end
      end
    end
  end
end
