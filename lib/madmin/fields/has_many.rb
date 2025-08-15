module Madmin
  module Fields
    class HasMany < Field
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

      def paginated_value(record, params, request)
        page_key = "#{attribute_name}_page"
        paginate value(record), page: params[page_key].to_i, page_key: page_key, request: request
      end

      if Gem::Version.new(Pagy::VERSION) >= Gem::Version.new("43.0.0.rc")
        include Pagy::Method

        def paginate(value, page:, page_key:, request:)
          pagy value, page: [page, 1].max, page_key: page_key, request: request
          # rescue Pagy::RangeError
          #  pagy :series_nav, value, page: 1, page_param: page_param
        end
      else
        # Pagy 9 or earlier
        include Pagy::Backend

        def paginate(value, page:, page_key:, request: nil)
          pagy value, page: page, page_param: page_key
        rescue Pagy::OverflowError, Pagy::VariableError
          pagy value, page: 1, page_param: page_key
        end
      end
    end
  end
end
