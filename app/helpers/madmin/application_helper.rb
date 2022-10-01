module Madmin
  module ApplicationHelper
    include Pagy::Frontend

    # Converts a Rails version to a NPM version
    def npm_rails_version
      version = [
        Rails::VERSION::MAJOR,
        Rails::VERSION::MINOR,
        Rails::VERSION::TINY
      ].join(".")

      version += "-#{Rails::VERSION::PRE}" if Rails::VERSION::PRE
      version
    end

    def clear_search_params
      resource.index_path(sort: params[:sort], direction: params[:direction])
    end
  end
end
