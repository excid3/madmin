module Madmin
  module ApplicationHelper
    include Rails.application.routes.url_helpers

    # Links to the record's page in its resource. Renders the name without a
    # link when the resource's show route isn't drawn.
    def link_to_record(resource, record, **options)
      link_to resource.display_name(record), resource.show_path(record), **options
    rescue Madmin::MissingRoute
      resource.display_name(record)
    end

    def clear_search_params
      index_path_with(q: nil)
    end

    # The current index URL with some params changed, keeping the search,
    # scope, sort and filters. Any change goes back to the first page
    def index_path_with(**changes)
      resource.index_path(request.query_parameters.symbolize_keys.except(:page).merge(changes))
    end
  end
end
