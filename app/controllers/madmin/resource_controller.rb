module Madmin
  class ResourceController < Madmin::ApplicationController
    include SortHelper

    before_action :set_record, except: [:index, :new, :create]
    before_action :enforce_readonly, only: [:new, :create, :edit, :update, :destroy]

    # Assign current_user for paper_trail gem
    before_action :set_paper_trail_whodunnit, if: -> { respond_to?(:set_paper_trail_whodunnit, true) }

    def index
      @page, @records = paginate_collection(scoped_resources)

      respond_to do |format|
        format.html
        format.json {
          render json: @records.map { |r| {name: @resource.display_name(r), id: r.id} }
        }
      end
    end

    def show
    end

    def new
      @record = resource.model.new(new_resource_params)
    end

    def create
      @record = resource.model.new
      if save_record(resource_params)
        redirect_to resource.show_path(@record)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if save_record(resource_params)
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
      resources = Madmin::Search.new(resources, resource, search_term, filters).run

      return resources if sort_column.blank?

      resources.reorder(sort_column => sort_direction)
    end

    # Returns [page, records]. Override for non-ActiveRecord collections and
    # return an object responding to the Madmin::Page interface.
    def paginate_collection(collection)
      paginate(collection, page: params[:page])
    end

    def valid_scope
      scope = params.fetch(:scope, "all")
      resource.scopes.include?(scope.to_sym) ? scope : :all
    end

    def resource_params
      cast_fields params.require(resource.param_key).permit(*resource.permitted_params)
    end

    def new_resource_params
      cast_fields params.fetch(resource.param_key, {}).permit!.permit(*resource.permitted_params)
    end

    # Lets each field convert its submitted value, such as parsing JSON
    def cast_fields(attributes)
      attributes.to_h.to_h do |name, value|
        field = field_for(name)
        [name, field ? field.cast(value) : value]
      end
    end

    # Assigns the attributes and saves, unless a field doesn't accept its value
    def save_record(attributes)
      @record.assign_attributes(attributes)

      rejected = attributes.select { |name, value| field_for(name)&.accepts?(value) == false }.keys

      if rejected.any?
        @record.validate
        rejected.each { |name| @record.errors.add(name, :invalid) }
        false
      else
        @record.save
      end
    end

    def field_for(name)
      resource.get_attribute(name.to_sym)&.field
    end

    def search_term
      @search_term ||= params[:q].to_s.strip
    end

    # The index filters from `filters[][column]`, `filters[][operator]` and `filters[][value]`
    def filters
      @filters ||= Madmin::Filter.from_params(resource, Array.wrap(params[:filters]).grep(ActionController::Parameters))
    end
    helper_method :filters

    def enforce_readonly
      redirect_to resource.index_path, alert: t("madmin.flash.readonly", name: resource.friendly_name) if resource.readonly?
    end

    ActiveSupport.run_load_hooks(:madmin_resource_controller, self)
  end
end
