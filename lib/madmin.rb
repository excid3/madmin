require "madmin/engine"

require "pagy"

module Madmin
  autoload :Field, "madmin/field"
  autoload :Resource, "madmin/resource"

  module Fields
    autoload :Integer, "madmin/fields/integer"
    autoload :String, "madmin/fields/string"
    autoload :Text, "madmin/fields/text"
    autoload :Date, "madmin/fields/date"
    autoload :DateTime, "madmin/fields/date_time"
    autoload :Json, "madmin/fields/json"
    autoload :Enum, "madmin/fields/enum"
    autoload :Float, "madmin/fields/float"
    autoload :Time, "madmin/fields/time"
    autoload :BelongsTo, "madmin/fields/belongs_to"
    autoload :HasMany, "madmin/fields/has_many"
    autoload :HasOne, "madmin/fields/has_one"
    autoload :RichText, "madmin/fields/rich_text"
    autoload :Attachment, "madmin/fields/attachment"
    autoload :Attachments, "madmin/fields/attachments"
  end

  mattr_accessor :resources, default: []
end
