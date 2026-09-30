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
      resource.index_path(sort: params[:sort], direction: params[:direction], filters: filter_params)
    end
  end
end
