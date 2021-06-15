module Madmin
  module Fields
    class BelongsTo < Field
      def options_for_select(record)
        if (record = record.send(attribute_name))
          resource = Madmin.resource_for(record)
          [[resource.display_name(record), record.id]]
        else
          []
        end
      end

      def to_param
        "#{attribute_name}_id"
      end

      def index_path
        Madmin.resource_by_name(model.reflect_on_association(attribute_name).klass).index_path(format: :json)
      end
    end
  end
end
