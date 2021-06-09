require "madmin/engine"

require "pagy"

module Madmin
  autoload :Field, "madmin/field"
  autoload :GeneratorHelpers, "madmin/generator_helpers"
  autoload :Resource, "madmin/resource"

  module Fields
    autoload :Attachment, "madmin/fields/attachment"
    autoload :Attachments, "madmin/fields/attachments"
    autoload :BelongsTo, "madmin/fields/belongs_to"
    autoload :Boolean, "madmin/fields/boolean"
    autoload :Date, "madmin/fields/date"
    autoload :DateTime, "madmin/fields/date_time"
    autoload :Decimal, "madmin/fields/decimal"
    autoload :Enum, "madmin/fields/enum"
    autoload :Float, "madmin/fields/float"
    autoload :HasMany, "madmin/fields/has_many"
    autoload :HasOne, "madmin/fields/has_one"
    autoload :Integer, "madmin/fields/integer"
    autoload :Json, "madmin/fields/json"
    autoload :NestedHasMany, "madmin/fields/nested_has_many"
    autoload :Password, "madmin/fields/password"
    autoload :Polymorphic, "madmin/fields/polymorphic"
    autoload :RichText, "madmin/fields/rich_text"
    autoload :String, "madmin/fields/string"
    autoload :Text, "madmin/fields/text"
    autoload :Time, "madmin/fields/time"
  end

  class << self
    def resource_for(object)
      "#{object.class.name}Resource".constantize
    end

    def resources
      @resources ||= resource_names.map(&:constantize)
    end

    def reset_resources!
      @resources = nil
    end

    def resource_names
      root = Rails.root.join("app/madmin/resources/")
      files = Dir.glob(root.join("**/*.rb"))
      files.sort!.map! { |f| f.split(root.to_s).last.delete_suffix(".rb").classify }
    end
  end
end
