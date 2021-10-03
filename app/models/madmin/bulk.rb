module Madmin
  class Bulk
    include ActiveModel::Type

    attr_reader :pile, :resource

    def initialize(params)
      @pile = checked_resources(params[:bulk])
      @resource_name = params[:resource]
      @resource = "#{@resource_name}_resource".camelize.constantize
      @model = @resource_name.camelize.constantize
    end

    def destroy_bulk
      @model.destroy(pile_ids)
    end

    private

    def checked_resources(params)
      checked = params&.select { |k, v| Boolean.new.cast(v) }

      checked || {}
    end

    def pile_ids
      @pile.keys.map { |k| k.delete_prefix("#{@resource_name}_") }
    end
  end
end
