require "madmin/engine"

require "pagy"

module Madmin
  autoload :Field, "madmin/field"
  autoload :GeneratorHelpers, "madmin/generator_helpers"
  autoload :Resource, "madmin/resource"

  module Fields
    autoload :Boolean, "madmin/fields/boolean"
    autoload :Integer, "madmin/fields/integer"
    autoload :String, "madmin/fields/string"
    autoload :Text, "madmin/fields/text"
    autoload :Date, "madmin/fields/date"
    autoload :DateTime, "madmin/fields/date_time"
    autoload :Decimal, "madmin/fields/decimal"
    autoload :Json, "madmin/fields/json"
    autoload :Enum, "madmin/fields/enum"
    autoload :Float, "madmin/fields/float"
    autoload :Time, "madmin/fields/time"
    autoload :BelongsTo, "madmin/fields/belongs_to"
    autoload :Polymorphic, "madmin/fields/polymorphic"
    autoload :HasMany, "madmin/fields/has_many"
    autoload :HasOne, "madmin/fields/has_one"
    autoload :RichText, "madmin/fields/rich_text"
    autoload :Attachment, "madmin/fields/attachment"
    autoload :Attachments, "madmin/fields/attachments"
  end

  mattr_accessor :resources, default: []

  class << self
    def resource_for(object)
      Rails.application.eager_load!

      klass_name = object.class.name
      Madmin.resources.find { |r| r.model_name == klass_name }
    end
  end
end
