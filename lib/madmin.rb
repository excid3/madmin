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
    autoload :NestedHasOne, "madmin/fields/nested_has_one"
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

  class << self
    def resource_for(object)
      if object.is_a? ::ActiveStorage::Attached
        "ActiveStorage::AttachmentResource".constantize
      else
        begin
          "#{object.class.name}Resource".constantize
        rescue
          # For STI models, see if there's a superclass resource available
          if (column = object.class.inheritance_column) && object.class.column_names.include?(column)
            "#{object.class.superclass.base_class.name}Resource".constantize
          else
            raise
          end
        end
      end
    end

    def resource_by_name(name)
      "#{name}Resource".constantize
    end

    def resources
      @resources ||= resource_names.map(&:constantize)
    end

    def reset_resources!
      @resources = nil
      menu.reset
    end

    def resource_names
      root = Rails.root.join("app/madmin/resources/")
      files = Dir.glob(root.join("**/*.rb"))
      files.sort!.map! { |f| f.split(root.to_s).last.delete_suffix(".rb").classify }
    end
  end
end
