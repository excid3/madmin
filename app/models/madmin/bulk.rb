module Madmin
  class Bulk
    include ActiveModel::Type

    attr_reader :pile, :resource

    def initialize(params)
      @pile = checked_resources(params[:bulk])
      @resource = "#{params[:resource]}Resource".constantize
      @model = params[:resource].constantize
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
      @pile.keys
    end
  end
end
