require "madmin/engine"
require "importmap-rails"
require "stimulus-rails"
require "turbo-rails"

module Madmin
  autoload :Field, "madmin/field"
  autoload :Filter, "madmin/filter"
  autoload :GeneratorHelpers, "madmin/generator_helpers"
  autoload :MemberAction, "madmin/member_action"
  autoload :Menu, "madmin/menu"
  autoload :Page, "madmin/page"
  autoload :Pagination, "madmin/pagination"
  autoload :Resource, "madmin/resource"
  autoload :ResourceBuilder, "madmin/resource_builder"
  autoload :Search, "madmin/search"

  module Fields
    autoload :Array, "madmin/fields/array"
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
  mattr_accessor :per_page, default: 20
  mattr_accessor :site_name
  mattr_accessor :stylesheets, default: []
  mattr_accessor :resource_locations, default: []

  class MissingResource < StandardError
  end

  class MissingRoute < StandardError
  end

  class << self
    # Returns a Madmin::Resource class for the given object
    def resource_for(object)
      if (resource_name = resource_name_for(object)) && Object.const_defined?(resource_name)
        resource_name.constantize

      # STI models should look at the parent
      elsif (resource_name = sti_resource_name_for(object)) && Object.const_defined?(resource_name)
        resource_name.constantize

      # A resource named differently from its model (`ArticleResource` for
      # `Blog::Post`) still says which model it is for with `model`. Honor that
      # declaration before giving up, so association cells can link to it.
      elsif (resource = resource_declaring(object.class))
        resource

      else
        raise MissingResource, <<~MESSAGE
          `#{object.class.name}Resource` is missing.

          Create the Madmin resource by running:

              bin/rails generate madmin:resource #{object.class.name}
        MESSAGE
      end
    end

    # The one resource whose `model` is +klass+ or, failing that, its nearest
    # superclass, or nil. Two resources declaring the same model with neither
    # matching its name is ambiguous, and guessing would silently link to the
    # wrong admin page, so that raises.
    def resource_declaring(klass)
      declared = klass.ancestors.grep(Class).find { |ancestor| resources_by_model.key?(ancestor) }
      return unless declared

      candidates = resources_by_model[declared]
      return candidates.first if candidates.one?

      raise MissingResource, <<~MESSAGE
        `#{declared.name}Resource` is missing, and #{candidates.map(&:name).join(", ")} all declare `model #{declared.name}`.

        Madmin can't tell which one to use. Name one of them `#{declared.name}Resource`.
      MESSAGE
    end

    def resources_by_model
      @resources_by_model ||= resources.group_by(&:model)
    end

    def resource_name_for(object)
      if object.is_a? ::ActiveStorage::Attached
        "ActiveStorage::AttachmentResource"
      else
        "#{object.class.name}Resource"
      end
    end

    def sti_resource_name_for(object)
      return unless object.class.respond_to?(:inheritance_column) && object.class.respond_to?(:column_names)

      if (column = object.class.inheritance_column) && object.class.column_names.include?(column)
        "#{object.class.superclass.base_class.name}Resource"
      end
    end

    # Returns the Madmin::Resource class for a model or model name, falling
    # back to the resource that declares the model when none is named after it
    def resource_by_name(name)
      "#{name}Resource".constantize
    rescue NameError
      model = name.is_a?(Class) ? name : name.to_s.safe_constantize
      resource = resource_declaring(model) if model
      return resource if resource

      raise MissingResource, <<~MESSAGE
        #{name}Resource is missing. Create it by running:

            bin/rails generate madmin:resource #{name}
      MESSAGE
    end

    def resources
      @resources ||= resource_names.map(&:constantize)
    end

    def reset_resources!
      @resources = nil
      @resources_by_model = nil
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
