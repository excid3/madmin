# based on Administrate Search: https://github.com/thoughtbot/administrate/blob/main/lib/administrate/search.rb

module Madmin
  class Search
    FILTER_OPERATORS = {
      # Equality
      "eq" => "=",
      "not_eq" => "!=",

      # Comparison
      "lt" => "<",
      "lte" => "<=",
      "gt" => ">",
      "gte" => ">=",

      # Text patterns
      "starts_with" => "LIKE",
      "ends_with" => "LIKE",
      "contains" => "LIKE",
      "not_contains" => "NOT LIKE",

      # Specials
      "is_null" => "IS NULL",
      "is_not_null" => "IS NOT NULL",
      "in" => "IN",
      "not_in" => "NOT IN"
    }.freeze

    attr_reader :query, :filters

    def initialize(scoped_resource, resource, term, filters)
      @resource = resource
      @scoped_resource = scoped_resource
      @query = term
      @filters = filters
    end

    def run
      scope = @scoped_resource
      scope = apply_search(scope) if query.present?
      scope = apply_filters(scope) if filters.present?
      scope
    end

    private

    def apply_search(scope)
      scope.where(query_template, *query_values)
    end

    def query_template
      search_attributes.map do |attr|
        table_name = query_table_name
        searchable_fields(attr).map do |field|
          column_name = column_to_query(field)
          "LOWER(CAST(#{table_name}.#{column_name} AS CHAR(256))) LIKE ?"
        end.join(" OR ")
      end.join(" OR ")
    end

    def searchable_fields(attr)
      [attr.name]
    end

    def query_values
      fields_count = search_attributes.sum do |attr|
        searchable_fields(attr).count
      end
      ["%#{@query.downcase}%"] * fields_count
    end

    def search_attributes
      @resource.searchable_attributes
    end

    def apply_filters(scope)
      groups = filters[:groups].to_h

      groups.each do |group_id, group_data|
        conditions = group_data["conditions"] || {}
        match_type = group_data["match_type"] || "all"

        next if conditions.empty?

        group_conditions = conditions.map do |condition_id, condition|
          column = condition["column"]
          operator = condition["operator"]
          value = condition["value"]
          type = condition["type"]
          next unless column.in?(filterable_columns) && FILTER_OPERATORS.key?(operator)

          apply_single_filter(scope, column, operator, value, type)
        end.compact

        next if group_conditions.empty?

        group_scope = if match_type == "all"
          # AND all conditions together
          group_conditions.reduce { |result, condition| result.merge(condition) }
        else
          # OR all conditions together
          group_conditions.reduce { |result, condition| result.or(condition) }
        end

        scope = scope.merge(group_scope)
      end

      scope
    end

    def apply_single_filter(scope, column, operator, value, type)
      sql_operator = FILTER_OPERATORS[operator]
      table_name = query_table_name

      # Cast types if necessary
      if type == "boolean"
        value = value == "true"
      end

      case operator
      when "like", "not_like"
        scope.where("#{table_name}.#{column} #{sql_operator} ?", "%#{value}%")
      when "starts_with"
        scope.where("#{table_name}.#{column} #{sql_operator} ?", "#{value}%")
      when "ends_with"
        scope.where("#{table_name}.#{column} #{sql_operator} ?", "%#{value}")
      when "contains", "not_contains"
        scope.where("#{table_name}.#{column} #{sql_operator} ?", "%#{value}%")
      when "is_null", "is_not_null"
        scope.where("#{table_name}.#{column} #{sql_operator}")
      when "in", "not_in"
        scope.where("#{table_name}.#{column} #{sql_operator} (?)", Array(value))
      else
        scope.where("#{table_name}.#{column} #{sql_operator} ?", value)
      end
    end

    def filterable_columns
      @resource.sortable_columns
    end

    def query_table_name
      ::ActiveRecord::Base.connection.quote_column_name(@scoped_resource.table_name)
    end

    def column_to_query(attr)
      ::ActiveRecord::Base.connection.quote_column_name(attr)
    end
  end
end
