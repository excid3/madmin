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

      def index_path(format: :json)
        associated_resource&.index_path(format: format)
      end

      def associated_resource
        Madmin.resource_by_name(model.reflect_on_association(attribute_name).klass)
      rescue MissingResource
      end

      def associated_resource_for(object)
        Madmin.resource_for(object)
      rescue MissingResource
      end
    end
  end
end
