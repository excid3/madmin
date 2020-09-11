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
        to_s.chomp("Resource").classify.constantize
      end

      def scope(name)
        scopes << name
      end

      def attribute(name, type = nil, **options)
        attributes << options.merge(
          name: name,
          field: field_for_type(name, type)
        )
      end

      private

      def field_for_type(name, type)
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

          # Associations
          attachment: Fields::Attachment,
          attachments: Fields::Attachments,
          belongs_to: Fields::BelongsTo,
          has_many: Fields::HasMany,
          has_one: Fields::HasOne,
          rich_text: Fields::RichText
        }[type || infer_type(name)]
      end

      def infer_type(name)
        name_string = name.to_s

        if model.attribute_types.include?(name_string)
          model.attribute_types[name.to_s].type || :string
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
