module Madmin
  module SortHelper
    def sortable(column, title, options = {})
      matching_column = (column.to_s == sort_column)
      direction = sort_direction == "asc" ? "desc" : "asc"

      link_to request.params.merge(sort: column, direction: direction), options do
        concat title
        if matching_column
          concat " "
          concat tag.i(sort_direction == "asc" ? "▲" : "▼")
        end
      end
    end

    def sort_column
      resource.sortable_columns.include?(params[:sort]) ? params[:sort] : default_sort_column
    end

    def sort_direction
      ["asc", "desc"].include?(params[:direction]) ? params[:direction] : default_sort_direction
    end

    def default_sort_column
      resource.try(:default_sort_column) || "created_at"
    end

    def default_sort_direction
      resource.try(:default_sort_direction) || "desc"
    end
  end
end
