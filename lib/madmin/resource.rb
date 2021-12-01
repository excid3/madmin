module Madmin
  class Resource
    class_attribute :attributes, default: ActiveSupport::OrderedHash.new
    class_attribute :scopes, default: []

    class << self
      def inherited(base)
        base.attributes = attributes.dup
        base.scopes = scopes.dup
        super
      end

      def model
        @model ||= model_name.constantize
      end

      def model_find(id)
        friendly_model? ? model.friendly.find(id) : model.find(id)
      end

      def model_name
        to_s.chomp("Resource").classify
      end

      def scope(name)
        scopes << name
      end

      def get_attribute(name)
        attributes[name]
      end

      def attribute(name, type = nil, **options)
        type ||= infer_type(name)
        field = options[:field] || field_for_type(type)

        attributes[name] = OpenStruct.new(
          name: name,
          type: type,
          field: field.new(**options.merge(attribute_name: name, model: model, resource: self))
        )
      rescue => e
        builder = ResourceBuilder.new(model)
        raise ArgumentError, <<~MESSAGE
          Madmin couldn't find attribute or association '#{name}' on #{model} model.

          We searched these attributes and associations:
          #{(builder.attributes + builder.associations).join(", ")}

          This attribute is defined in a Madmin resource at:
          #{e.backtrace.find { |l| l =~ /_resource.rb/ }}

          Either add the missing attribute or assocation, or remove this line from your Madmin resource.
        MESSAGE
      end

      def friendly_name
        model_name.gsub("::", " / ").split(/(?=[A-Z])/).join(" ")
      end

      # Support for isolated namespaces
      # Finds parent module class to include in polymorphic urls
      def route_namespace
        return @route_namespace if instance_variable_defined?(:@route_namespace)
        namespace = model.module_parents.detect do |n|
          n.respond_to?(:use_relative_model_naming?) && n.use_relative_model_naming?
        end
        @route_namespace = (namespace ? namespace.name.singularize.underscore.to_sym : nil)
      end

      def index_path(options = {})
        url_helpers.polymorphic_path([:madmin, route_namespace, model], options)
      end

      def new_path
        url_helpers.polymorphic_path([:madmin, route_namespace, model], action: :new)
      end

      def show_path(record)
        url_helpers.polymorphic_path([:madmin, route_namespace, record])
      end

      def edit_path(record)
        url_helpers.polymorphic_path([:madmin, route_namespace, record], action: :edit)
      end

      def param_key
        model.model_name.param_key
      end

      def permitted_params
        attributes.values.filter_map { |a| a.field.to_param if a.field.visible?(:form) }
      end

      def display_name(record)
        "#{record.class} ##{record.id}"
      end

      def friendly_model?
        model.respond_to? :friendly
      end

      def sortable_columns
        model.column_names
      end

      def searchable_attributes
        attributes.values.select { |a| a.field.searchable? }
      end

      private

      def field_for_type(type)
        {
          binary: Fields::String,
          blob: Fields::Text,
          boolean: Fields::Boolean,
          date: Fields::Date,
          datetime: Fields::DateTime,
          decimal: Fields::Decimal,
          enum: Fields::Enum,
          float: Fields::Float,
          hstore: Fields::Json,
          integer: Fields::Integer,
          json: Fields::Json,
          jsonb: Fields::Json,
          primary_key: Fields::String,
          string: Fields::String,
          text: Fields::Text,
          time: Fields::Time,
          timestamp: Fields::Time,
          password: Fields::Password,
          file: Fields::File,

          # Postgres specific types
          bit: Fields::String,
          bit_varying: Fields::String,
          box: Fields::String,
          cidr: Fields::String,
          circle: Fields::String,
          citext: Fields::Text,
          daterange: Fields::String,
          inet: Fields::String,
          int4range: Fields::String,
          int8range: Fields::String,
          interval: Fields::String,
          line: Fields::String,
          lseg: Fields::String,
          ltree: Fields::String,
          macaddr: Fields::String,
          money: Fields::String,
          numrange: Fields::String,
          oid: Fields::String,
          path: Fields::String,
          point: Fields::String,
          polygon: Fields::String,
          tsrange: Fields::String,
          tstzrange: Fields::String,
          tsvector: Fields::String,
          uuid: Fields::String,
          xml: Fields::Text,

          # Associations
          attachment: Fields::Attachment,
          attachments: Fields::Attachments,
          belongs_to: Fields::BelongsTo,
          polymorphic: Fields::Polymorphic,
          has_many: Fields::HasMany,
          has_one: Fields::HasOne,
          rich_text: Fields::RichText,
          nested_has_many: Fields::NestedHasMany
        }.fetch(type)
      end

      def infer_type(name)
        name_string = name.to_s

        if model.attribute_types.include?(name_string)
          column_type = model.attribute_types[name_string]
          if column_type.is_a? ActiveRecord::Enum::EnumType
            :enum
          else
            column_type.type || :string
          end
        elsif (association = model.reflect_on_association(name))
          type_for_association(association)
        elsif model.reflect_on_association(:"rich_text_#{name_string}")
          :rich_text
        elsif model.reflect_on_association(:"#{name_string}_attachment")
          :attachment
        elsif model.reflect_on_association(:"#{name_string}_attachments")
          :attachments

        # has_secure_password
        elsif model.attribute_types.include?("#{name_string}_digest") || name_string.ends_with?("_confirmation")
          :password

          # ActiveRecord Store
        elsif model_store_accessors.include?(name)
          :string
        end
      end

      def type_for_association(association)
        if association.has_one?
          :has_one
        elsif association.collection?
          :has_many
        elsif association.polymorphic?
          :polymorphic
        else
          :belongs_to
        end
      end

      def url_helpers
        @url_helpers ||= Rails.application.routes.url_helpers
      end

      def model_store_accessors
        store_accessors = model.stored_attributes.values

        store_accessors.flatten
      end
    end
  end
end
