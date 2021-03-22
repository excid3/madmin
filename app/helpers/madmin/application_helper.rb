module Madmin
  module ApplicationHelper
    include Pagy::Frontend

    # Converts a Rails version to a NPM version
    def npm_rails_version
      version = [
        Rails::VERSION::MAJOR,
        Rails::VERSION::MINOR,
        Rails::VERSION::TINY
      ].join(".")

      version += "-#{Rails::VERSION::PRE}" if Rails::VERSION::PRE
      version
    end

    def link_to_add_association(name, resource:, form:, field:, html_options: {})
      record = form.object.send(field.attribute_name).build

      attribute = field.attribute_name.to_s.singularize

      name = "#{name} #{attribute}"
      html_options[:class]= "#{html_options[:class]} add_fields"
      html_options[:'data-association-insert-template'] = CGI.escapeHTML(form_template(form, field, resource, record, attribute))

      link_to(name, '#', html_options)
    end

    def form_template(form, field, resource, record, attribute)
      form_fields = form.fields_for field.attribute_name, child_index: "new_#{attribute}" do |nested_form|
        render(partial: "./madmin/application/fields", locals: { resource: resource, record: record, form: nested_form })
      end

      "<div class='bg-gray-100 rounded-t-xl p-5'>#{form_fields}</div>"
    end

  end
end
