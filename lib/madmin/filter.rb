module Madmin
  # One condition from the index filters, like `created_at gte 2026-08-15T09:00`
  class Filter
    OPERATORS = {
      string: %w[contains eq starts_with blank present],
      number: %w[eq gt gte lt lte blank],
      date: %w[eq gte lte blank],
      datetime: %w[gte lte blank],
      boolean: %w[true false]
    }.freeze

    WITHOUT_VALUE = %w[blank present true false].freeze

    attr_reader :field, :operator, :value

    # Skips conditions for unknown columns or operators, and values that don't
    # cast to the column's type
    def self.from_params(resource, params)
      Array(params).filter_map do |param|
        attribute = resource.attributes[param[:column].to_s.to_sym]
        filter = new(attribute.field, param[:operator].to_s, param[:value].to_s) if attribute&.field&.filter_type
        filter if filter&.valid?
      end
    end

    def initialize(field, operator, value)
      @field = field
      @operator = operator
      @value = value
    end

    def column
      field.attribute_name.to_s
    end

    def type
      field.filter_type
    end

    def value?
      WITHOUT_VALUE.exclude?(operator)
    end

    def valid?
      OPERATORS.fetch(type, []).include?(operator) && (!value? || !cast_value.nil?)
    end

    def apply(scope)
      attribute = scope.arel_table[column]

      case operator
      when "contains" then scope.where(attribute.matches("%#{escaped_value}%"))
      when "starts_with" then scope.where(attribute.matches("#{escaped_value}%"))
      when "eq" then scope.where(column => cast_value)
      when "gt" then scope.where(attribute.gt(cast_value))
      when "gte" then scope.where(attribute.gteq(cast_value))
      when "lt" then scope.where(attribute.lt(cast_value))
      when "lte" then scope.where(attribute.lteq(cast_value))
      when "blank" then scope.where(column => blank_values)
      when "present" then scope.where.not(column => blank_values)
      when "true" then scope.where(column => true)
      when "false" then scope.where(column => false)
      end
    end

    # The params for this filter, used to keep it in links
    def to_h
      {column: column, operator: operator, value: value}
    end

    private

    # Datetimes are parsed in Time.zone, like form input
    def cast_value
      @cast_value ||= value.presence && field.model.type_for_attribute(column).cast(value)
    end

    def escaped_value
      field.model.sanitize_sql_like(value)
    end

    def blank_values
      (type == :string) ? [nil, ""] : nil
    end
  end
end
