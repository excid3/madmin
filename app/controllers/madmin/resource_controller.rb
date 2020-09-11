module Madmin
  class ResourceController < ApplicationController
    before_action :set_record, except: [:index, :new, :create]

    def index
      @pagy, @records = pagy(resource.model.all)
    end

    def show
    end

    def new
      @record = resource.model.new
    end

    def create
    end

    def edit
    end

    def update
    end

    def destroy
    end

    private

    def set_record
      @record = resource.model.find(params[:id])
    end

    def resource
      @resource ||= resource_name.constantize
    end
    helper_method :resource

    def resource_name
      "#{controller_path.singularize}_resource".delete_prefix("madmin/").classify
    end
  end
end
