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
      params.except(:q, :_page).permit(:page, :sort, :direction)
    end
  end
end
