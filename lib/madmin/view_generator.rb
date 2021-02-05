require "rails/generators/base"
require "madmin/generator_helpers"
require "madmin/namespace"

module Madmin
  class ViewGenerator < Rails::Generators::Base
    include Madmin::GeneratorHelpers
    class_option :namespace, type: :string, default: "madmin"

    def self.template_source_path
      File.expand_path(
        "../../../app/views/madmin/application",
        __FILE__
      )
    end

    private

    def namespace
      options[:namespace]
    end

    def copy_resource_template(template_name)
      template_file = "#{template_name}.html.erb"

      copy_file(
        template_file,
        "app/views/#{namespace}/#{resource_path}/#{template_file}"
      )
    end

    def resource_path
      args.first.try(:underscore).try(:pluralize) || BaseResourcePath.new
    end

    class BaseResourcePath
      def to_s
        "application"
      end
    end
  end
end
