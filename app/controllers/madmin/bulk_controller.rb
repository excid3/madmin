module Madmin
  class BulkController < ApplicationController
    # Assign current_user for paper_trail gem
    before_action :set_paper_trail_whodunnit, if: -> { respond_to?(:set_paper_trail_whodunnit, true) }

    def destroy
      if params[:all]
        @records = resource.model.destroy_all
      else
        @records = resource.model.where(id: params[:ids]).destroy_all
      end

      redirect_to resource.index_path
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
