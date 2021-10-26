module Madmin
  class BulkController < ApplicationController
    before_action :set_bulk

    def destroy
      model.destroy(bulk_ids)

      redirect_to resource.index_path
    end

    private

    def set_bulk
      @bulk = params[:bulk]&.select { |k, v| ActiveModel::Type::Boolean.new.cast(v) }

      @bulk || {}
    end

    def model
      params[:resource].constantize
    end

    def resource
      "#{params[:resource]}Resource".constantize
    end

    def bulk_ids
      @bulk.keys
    end
  end
end
