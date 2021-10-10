module Madmin
  class ResourceController < Madmin::ApplicationController
    include SortHelper

    before_action :set_record, except: [:index, :new, :create]

    # Assign current_user for paper_trail gem
    before_action :set_paper_trail_whodunnit, if: -> { respond_to?(:set_paper_trail_whodunnit, true) }

    def index
      @pagy, @records = pagy(scoped_resources)

      respond_to do |format|
        format.html
        format.json {
          render json: {data: @records.map { |r|
                                {id: r.id,
                                 name: @resource.display_name(r),
                                 details: @resource.details(r)}
                              },
                        next_page: pagy_metadata(@pagy).fetch(:next)}
        }
      end
    rescue Pagy::OverflowError
      params[:page] = 1
      retry
    end

    def show
    end

    def new
      @record = resource.model.new
    end

    def create
      @record = resource.model.new(resource_params)
      if @record.save
        redirect_to resource.show_path(@record)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @record.update(resource_params)
        redirect_to resource.show_path(@record)
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @record.destroy
      redirect_to resource.index_path
    end

    private

    def set_record
      @record = resource.model_find(params[:id])
    end

    def resource
      @resource ||= resource_name.constantize
    end
    helper_method :resource

    def resource_name
      "#{controller_path.singularize}_resource".delete_prefix("madmin/").classify
    end

    def scoped_resources
      resources = resource.model.send(valid_scope)
      resources = Madmin::Search.new(resources, resource, search_term).run
      resources.reorder(sort_column => sort_direction)
    end

    def valid_scope
      scope = params.fetch(:scope, "all")
      resource.scopes.include?(scope.to_sym) ? scope : :all
    end

    def resource_params
      params.require(resource.param_key)
        .permit(*resource.permitted_params)
        .transform_values { |v| change_polymorphic(v) }
    end

    def change_polymorphic(data)
      return data unless data.is_a?(ActionController::Parameters) && data[:type]

      if data[:type] == "polymorphic"
        GlobalID::Locator.locate(data[:value])
      else
        raise "Unrecognised param data: #{data.inspect}"
      end
    end

    def search_term
      @search_term ||= params[:q].to_s.strip
    end
  end
end
