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

      def paginateable?
        true
      end

      def paginated_value(record, params)
        param_name = "#{attribute_name}_page"
        pagy value(record), page: params[param_name].to_i, page_param: param_name
      rescue Pagy::OverflowError, Pagy::VariableError
        pagy value(record), page: 1, page_param: param_name
      end
    end
  end
end
