module Madmin
  module Fields
    class HasMany < Field
      def options_for_select(record)
        association = record.class.reflect_on_association(attribute_name)
        klass = association.klass
        resource = nil
        klass.all.map do |r|
          resource ||= Madmin.resource_for(r)
          [resource.display_name(r), r.id]
        end
      end

      def to_param
        {"#{attribute_name.to_s.singularize}_ids".to_sym => []}
      end
    end
  end
end
