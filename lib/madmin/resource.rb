module Madmin
  class Resource
    class_attribute :attributes, default: []
    class_attribute :scopes, default: []

    class << self
      def inherited(base)
        base.attributes = attributes.dup
        base.scopes = scopes.dup
        super
      end

      def model
        model_name.constantize
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

      def attribute(name, type = nil, **options)
        attributes << {
          name: name,
          field: field_for_type(name, type).new(**options.merge(attribute_name: name, model: model))
        }
      end

      def friendly_name
        model_name.gsub("::", " / ")
      end

      def index_path(options = {})
        route_name = "madmin_#{model.table_name}_path"

        url_helpers.send(route_name, options)
      end

      def new_path
        route_name = "new_madmin_#{model.model_name.singular}_path"

        url_helpers.send(route_name)
      end

      def show_path(record)
        route_name = "madmin_#{model.model_name.singular}_path"

        url_helpers.send(route_name, record.to_param)
      end

      def edit_path(record)
        route_name = "edit_madmin_#{model.model_name.singular}_path"

        url_helpers.send(route_name, record.to_param)
      end

      def param_key
        model.model_name.param_key
      end

      def permitted_params
        attributes.filter_map { |a| a[:field].to_param if a[:field].visible?(:form) }
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

      private

      def field_for_type(name, type)
        type ||= infer_type(name)

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
      rescue
        raise ArgumentError, <<~MESSAGE
          Couldn't find attribute or association '#{name}' with type '#{type}' on #{model} model

            To fix this, either:

            1. Remove 'attribute #{name}' from app/madmin/resources/#{model.to_s.underscore}_resource.rb
            2. Or add the missing attribute or association to the #{model} model
        MESSAGE
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
    end
  end
end
