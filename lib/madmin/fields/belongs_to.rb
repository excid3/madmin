module Madmin
  module Fields
    class BelongsTo < Field
      def options_for_select(record)
        association = record.class.reflect_on_association(attribute_name)

        # Polymorphic associations could be against any model
        # So we cannot provide a list of models by default
        return [] if association.polymorphic?

        association.klass.all.map do |r|
          ["#{klass.name} ##{r.id}", r.id]
        end
      end

      def to_param
        "#{attribute_name}_id"
      end
    end
  end
end
