module Madmin
  module SortHelper
    def sortable(klass, column, title, options = {})
      matching_column = column.to_s == sort_column(klass)
      direction = sort_direction == "asc" ? "desc" : "asc"

      link_to request.params.merge(sort: column, direction: direction), options do
        concat title
        if matching_column
          caret = sort_direction == "asc" ? "up" : "down"
          concat " "
          concat tag.i(caret == "up" ? "▲" : "▼")
        end
      end
    end

    def sort_column(klass)
      klass.sortable_columns.include?(params[:sort]) ? params[:sort] : "created_at"
    end

    def sort_direction(default: "asc")
      ["asc", "desc"].include?(params[:direction]) ? params[:direction] : default
    end
  end
end
