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
      params.map { |param| new(resource.get_attribute(param[:column].to_s.to_sym)&.field, param[:operator].to_s, param[:value].to_s) }.select(&:valid?)
    end

    # A new row in the filters form, for the first filterable column
    def self.blank(resource)
      field = resource.filterable_attributes.first.field
      new(field, OPERATORS.fetch(field.filter_type).first, "")
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
      field&.filter_type.present? && OPERATORS[type].include?(operator) && (typed_value.present? || !value?)
    end

    def apply(scope)
      attribute = scope.arel_table[column]

      case operator
      when "contains" then scope.where(attribute.matches("%#{escaped_value}%"))
      when "starts_with" then scope.where(attribute.matches("#{escaped_value}%"))
      when "eq" then scope.where(column => typed_value)
      when "gt" then scope.where(attribute.gt(typed_value))
      when "gte" then scope.where(attribute.gteq(typed_value))
      when "lt" then scope.where(attribute.lt(typed_value))
      when "lte" then scope.where(attribute.lteq(typed_value))
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

    # The value in the column's type. Datetimes are parsed in Time.zone, like form input
    def typed_value
      @typed_value ||= value.presence && field.model.type_for_attribute(column).cast(value)
    end

    private

    def escaped_value
      field.model.sanitize_sql_like(value)
    end

    def blank_values
      (type == :string) ? [nil, ""] : nil
    end
  end
end
