module Madmin
  class Resource
    class_attribute :attributes, default: []
    class_attribute :scopes, default: []

    class << self
      def inherited(base)
        # Remove any old references
        Madmin.resources.delete(base)
        Madmin.resources << base

        base.attributes = attributes.dup
        base.scopes = scopes.dup
        super
      end

      def model
        model_name.constantize
      end

      def model_name
        to_s.chomp("Resource").classify
      end

      def scope(name)
        scopes << name
      end

      def attribute(name, type = nil, **options)
        attributes << options.merge(
          name: name,
          field: field_for_type(name, type).new(attribute_name: name, collection: options[:collection])
        )
      end

      def friendly_name
        model_name.gsub("::", " / ")
      end

      def index_path
        "/madmin/#{model.model_name.collection}"
      end

      def new_path
        "/madmin/#{model.model_name.collection}/new"
      end

      def show_path(record)
        "/madmin/#{model.model_name.collection}/#{record.id}"
      end

      def edit_path(record)
        "/madmin/#{model.model_name.collection}/#{record.id}/edit"
      end

      def param_key
        model.model_name.param_key
      end

      def permitted_params
        attributes.map { |a| a[:field].to_param }
      end

      def display_name(record)
        "#{record.class} ##{record.id}"
      end

      private

      def field_for_type(name, type)
        type ||= infer_type(name)

        {
          date: Fields::Date,
          datetime: Fields::DateTime,
          enum: Fields::Enum,
          float: Fields::Float,
          integer: Fields::Integer,
          json: Fields::Json,
          string: Fields::String,
          text: Fields::Text,
          time: Fields::Time,
          boolean: Fields::Boolean,

          # Associations
          attachment: Fields::Attachment,
          attachments: Fields::Attachments,
          belongs_to: Fields::BelongsTo,
          polymorphic: Fields::Polymorphic,
          has_many: Fields::HasMany,
          has_one: Fields::HasOne,
          rich_text: Fields::RichText
        }.fetch(type)
      end

      def infer_type(name)
        name_string = name.to_s

        if model.attribute_types.include?(name_string)
          model.attribute_types[name_string].type || :string
        elsif (association = model.reflect_on_association(name))
          type_for_association(association)
        elsif model.reflect_on_association(:"rich_text_#{name_string}")
          :rich_text
        elsif model.reflect_on_association(:"#{name_string}_attachment")
          :attachment
        elsif model.reflect_on_association(:"#{name_string}_attachments")
          :attachments
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
    end
  end
end
