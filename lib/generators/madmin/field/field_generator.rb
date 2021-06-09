module Madmin
  module Generators
    class FieldGenerator < Rails::Generators::NamedBase
      include Madmin::GeneratorHelpers

      source_root File.expand_path("../templates", __FILE__)

      def eager_load
        Rails.application.eager_load!
      end

      def generate_field
        template "field.rb", "app/madmin/fields/#{file_path}_field.rb"
        copy_resource_template "_form"
        copy_resource_template "_index"
        copy_resource_template "_show"
      end

      private

      def copy_resource_template(template_name)
        template_file = "#{template_name}.html.erb"

        copy_file(
          template_file,
          "app/views/madmin/fields/#{file_path}_field/#{template_file}"
        )
      end
    end
  end
end
