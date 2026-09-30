module Madmin
  module FiltersHelper
    FILTER_INPUT_TYPES = {string: "text", number: "number", date: "date", datetime: "datetime-local", boolean: "text"}.freeze

    def filter_operator_options(type)
      Filter::OPERATORS.fetch(type).map { |operator| [t("madmin.filters.operators.#{type}.#{operator}"), operator] }
    end

    # Operator options for every type, so the filters controller can switch them when the column changes
    def filter_operators
      Filter::OPERATORS.keys.index_with { |type| filter_operator_options(type) }
    end

    # The active filters as params for links, leaving out `except`
    def filter_params(except: nil)
      (filters - [except]).map(&:to_h).presence
    end

    # Keeps the search, scope and sort when filters change
    def index_params
      params.slice(:q, :scope, :sort, :direction).permit!.to_h.symbolize_keys
    end

    def filter_value_label(filter)
      case filter.type
      when :date then l(filter.value.to_date, format: :long)
      when :datetime then l(Time.zone.parse(filter.value), format: :long)
      else filter.value
      end
    rescue ArgumentError
      filter.value
    end
  end
end
