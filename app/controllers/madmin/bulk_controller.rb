module Madmin
  class BulkController < ApplicationController
    # Assign current_user for paper_trail gem
    before_action :set_paper_trail_whodunnit, if: -> { respond_to?(:set_paper_trail_whodunnit, true) }

    def destroy
      @records = resource.model.where(id: params[:ids]).destroy_all

      head :ok
    end

    private

    def resource
      @resource ||= resource_name.constantize
    end
    helper_method :resource

    def resource_name
      "#{params[:resource].singularize}_resource".classify
    end
  end
end
