module Madmin
  module Fields
    class HasMany < Field
      include Pagy::Backend

      def options_for_select(record)
        if (records = record.send(attribute_name))
          return [] unless records.first
          resource = Madmin.resource_for(records.first)
          records.map { |record| [resource.display_name(record), record.id] }
        else
          []
        end
      end

      def to_param
        {"#{attribute_name.to_s.singularize}_ids": []}
      end

      def index_path
        Madmin.resource_by_name(model.reflect_on_association(attribute_name).klass).index_path(format: :json)
      end

      def paginateable?
        true
      end

      def paginated_value(record, params)
        pagy value(record), page: params.fetch("#{attribute_name}_page", 1), page_param: "#{attribute_name}_page"
      end
    end
  end
end
