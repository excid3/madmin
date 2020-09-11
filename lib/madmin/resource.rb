module Madmin
  class Resource
    class_attribute :attributes, default: []
    class_attribute :scopes, default: []

    class << self
      def model
        to_s.chomp("Resource").classify.constantize
      end

      def scope(name)
        self.scopes << name
      end

      def attribute(name, type=nil, **options)
        self.attributes << options.merge(
          name: name,
          field: field_for_type(type)
        )
      end

      private

      def field_for_type(type)
        {
          integer: Object,
          string: Object,
          text: Object,
          date: Object,
          datetime: Object,
          json: Object,
          enum: Object,
          float: Object,
          time: Object,

          # Associations
          belongs_to: Object,
          has_many: Object,
          has_one: Object,
          rich_text: Object,
          file: Object,
          files: Object,
        }[type || infer_type(type)]
      end

      def infer_type(name)
        name_string = name.to_s

        if model.attribute_types.include?(name_string)
          model.attribute_types[name.to_s].type || :string
        elsif (association = model.reflect_on_association(name))
          type_for_association(association)
        elsif (association = model.reflect_on_association(:"rich_text_#{name_string}"))
          :rich_text
        elsif (association = model.reflect_on_association(:"#{name_string}_attachment"))
          :file
        elsif (association = model.reflect_on_association(:"#{name_string}_attachments"))
          :files
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
