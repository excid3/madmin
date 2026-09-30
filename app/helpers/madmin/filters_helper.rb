module Madmin
  module FiltersHelper
    FILTER_INPUT_TYPES = {string: "text", number: "number", date: "date", datetime: "datetime-local", boolean: "text", array: "text"}.freeze

    # Operators that don't take a value are marked so the filters controller can hide the value input
    def filter_operator_options(type)
      Filter::OPERATORS.fetch(type).map do |operator|
        option = [t("madmin.filters.operators.#{type}.#{operator}"), operator]
        Filter::WITHOUT_VALUE.include?(operator) ? option << {data: {without_value: true}} : option
      end
    end

    def filter_column_options(resource)
      resource.filterable_attributes.map do |attribute|
        type = attribute.field.filter_type
        [attribute.field.label, attribute.name, {data: {input_type: filter_input_type(type), filter_type: type}}]
      end
    end

    def filter_input_type(type) = FILTER_INPUT_TYPES.fetch(type)

    def filter_value_label(filter)
      filter.type.in?([:date, :datetime]) ? l(filter.typed_value, format: :long) : filter.value
    end
  end
end
