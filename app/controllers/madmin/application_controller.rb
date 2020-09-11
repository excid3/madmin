module Madmin
  class ApplicationController < ActionController::Base
    include Pagy::Backend

    protect_from_forgery with: :exception

    def index
      @pagy, @records = pagy(resource.model.all)
    end

    private

    def resource
      @resource ||= resource_name.constantize
    end
    helper_method :resource

    def resource_name
      "#{controller_path.singularize}_resource".delete_prefix("madmin/").classify
    end
  end
end
