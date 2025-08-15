module Madmin
  module ApplicationHelper
    include Pagy::Frontend if defined? Pagy::Frontend
    include Rails.application.routes.url_helpers

    def clear_search_params
      resource.index_path(sort: params[:sort], direction: params[:direction])
    end
  end
end
