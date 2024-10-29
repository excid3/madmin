module Madmin
  module ApplicationHelper
    include Pagy::Frontend

    def clear_search_params
      resource.index_path(sort: params[:sort], direction: params[:direction])
    end
  end
end
