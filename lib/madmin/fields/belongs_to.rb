module Madmin
  module Fields
    class BelongsTo < Field
      def options_for_select(record)
        records = if (record = record.send(attribute_name))
          [record]
        else
          associated_resource.model.first(25)
        end

        records.map { [Madmin.resource_for(_1).display_name(_1), _1.id] }
      end

      def to_param
        "#{attribute_name}_id"
      end

      def index_path
        associated_resource.index_path(format: :json)
      end

      def associated_resource
        Madmin.resource_by_name(model.reflect_on_association(attribute_name).klass)
      end
    end
  end
end
