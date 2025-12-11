require "madmin/engine"

require "pagy"

module Madmin
  autoload :Field, "madmin/field"
  autoload :GeneratorHelpers, "madmin/generator_helpers"
  autoload :Menu, "madmin/menu"
  autoload :Resource, "madmin/resource"
  autoload :ResourceBuilder, "madmin/resource_builder"
  autoload :Search, "madmin/search"

  module Fields
    autoload :Attachment, "madmin/fields/attachment"
    autoload :Attachments, "madmin/fields/attachments"
    autoload :BelongsTo, "madmin/fields/belongs_to"
    autoload :Boolean, "madmin/fields/boolean"
    autoload :Currency, "madmin/fields/currency"
    autoload :Date, "madmin/fields/date"
    autoload :DateTime, "madmin/fields/date_time"
    autoload :Decimal, "madmin/fields/decimal"
    autoload :Enum, "madmin/fields/enum"
    autoload :File, "madmin/fields/file"
    autoload :Float, "madmin/fields/float"
    autoload :HasMany, "madmin/fields/has_many"
    autoload :HasOne, "madmin/fields/has_one"
    autoload :Integer, "madmin/fields/integer"
    autoload :Json, "madmin/fields/json"
    autoload :NestedHasMany, "madmin/fields/nested_has_many"
    autoload :Password, "madmin/fields/password"
    autoload :Polymorphic, "madmin/fields/polymorphic"
    autoload :RichText, "madmin/fields/rich_text"
    autoload :Select, "madmin/fields/select"
    autoload :String, "madmin/fields/string"
    autoload :Text, "madmin/fields/text"
    autoload :Time, "madmin/fields/time"
  end

  mattr_accessor :importmap, default: Importmap::Map.new
  mattr_accessor :menu, default: Menu.new
  mattr_accessor :site_name
  mattr_accessor :stylesheets, default: []
  mattr_accessor :resource_locations, default: []

  class MissingResource < StandardError
  end

  class << self
    # Returns a Madmin::Resource class for the given object
    def resource_for(object)
      if (resource_name = resource_name_for(object)) && Object.const_defined?(resource_name)
        resource_name.constantize

      # STI models should look at the parent
      elsif (resource_name = sti_resource_name_for(object)) && Object.const_defined?(resource_name)
        resource_name.constantize

      else
        raise MissingResource, <<~MESSAGE
          `#{object.class.name}Resource` is missing.

          Create the Madmin resource by running:

              bin/rails generate madmin:resource #{object.class.name}
        MESSAGE
      end
    end

    def resource_name_for(object)
      if object.is_a? ::ActiveStorage::Attached
        "ActiveStorage::AttachmentResource"
      else
        "#{object.class.name}Resource"
      end
    end

    def sti_resource_name_for(object)
      if (column = object.class.inheritance_column) && object.class.column_names.include?(column)
        "#{object.class.superclass.base_class.name}Resource"
      end
    end

    def resource_by_name(name)
      "#{name}Resource".constantize
    rescue NameError
      raise MissingResource, <<~MESSAGE
        #{name}Resource is missing. Create it by running:

            bin/rails generate madmin:resource #{resource_name.split("Resource").first}
      MESSAGE
    end

    def resources
      @resources ||= resource_names.map(&:constantize)
    end

    def reset_resources!
      @resources = nil
      menu.reset
    end

    def resource_names
      resource_locations.flat_map do |root|
        files = Dir.glob(root.join("**/*.rb"))
        files.sort!.map! { |f| f.split(root.to_s).last.delete_suffix(".rb").classify }
      end
    end
  end
end
