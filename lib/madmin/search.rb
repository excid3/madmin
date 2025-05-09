# based on Administrate Search: https://github.com/thoughtbot/administrate/blob/main/lib/administrate/search.rb

module Madmin
  class Search
    attr_reader :query

    def initialize(scoped_resource, resource, term)
      @resource = resource
      @scoped_resource = scoped_resource
      @query = term
    end

    def run
      if query.blank?
        @scoped_resource.all
      else
        search_results(@scoped_resource)
      end
    end

    private

    def search_results(resources)
      resources.where(query_template, *query_values)
    end

    def query_template
      search_attributes.map do |attr|
        table_name = query_table_name(attr)
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
      ["%#{@query.mb_chars.downcase}%"] * fields_count
    end

    def search_attributes
      @resource.searchable_attributes
    end

    def query_table_name(attr)
      ::ActiveRecord::Base.connection.quote_column_name(@scoped_resource.table_name)
    end

    def column_to_query(attr)
      ::ActiveRecord::Base.connection.quote_column_name(attr)
    end
  end
end
