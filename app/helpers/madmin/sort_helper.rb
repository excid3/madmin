module Madmin
  module SortHelper
    def sortable(column, title, options = {})
      matching_column = (column.to_s == sort_column)
      direction = (sort_direction == "asc") ? "desc" : "asc"

      link_to resource.index_path(sort: column, direction: direction, scope: params[:scope], q: params[:q]), options do
        concat title
        if matching_column
          concat " "
          concat tag.span((sort_direction == "asc") ? asc_icon : desc_icon)
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
      resource.try(:default_sort_column) || (["created_at", "id", "uuid"] & resource.model.column_names).first
    end

    def default_sort_direction
      resource.try(:default_sort_direction) || "desc"
    end

    def asc_icon
      <<~SVG.html_safe
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" fill="currentColor" height="1rem" width="1rem">
          <path fill-rule="evenodd" d="M11.78 9.78a.75.75 0 0 1-1.06 0L8 7.06 5.28 9.78a.75.75 0 0 1-1.06-1.06l3.25-3.25a.75.75 0 0 1 1.06 0l3.25 3.25a.75.75 0 0 1 0 1.06Z" clip-rule="evenodd" />
        </svg>
      SVG
    end

    def desc_icon
      <<~SVG.html_safe
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" fill="currentColor" height="1rem" width="1rem">
          <path fill-rule="evenodd" d="M4.22 6.22a.75.75 0 0 1 1.06 0L8 8.94l2.72-2.72a.75.75 0 1 1 1.06 1.06l-3.25 3.25a.75.75 0 0 1-1.06 0L4.22 7.28a.75.75 0 0 1 0-1.06Z" clip-rule="evenodd" />
        </svg>
      SVG
    end
  end
end
