module Madmin
  class BulkController < ApplicationController
    def destroy
      bulk = Madmin::Bulk.new(params)
      bulk.destroy_bulk

      redirect_to bulk.resource.index_path
    end
  end
end
