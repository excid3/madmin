# frozen_string_literal: true

module Madmin
  module RoutesHelper
    # True when a route matching the HTTP method exists for the path returned by the block.
    # The block runs inside the rescue because polymorphic path helpers are undefined
    # when the corresponding routes are not drawn.
    #
    #   route?(method: :delete) { resource.show_path(record) }
    #   route?(method: :get) { resource.edit_path(record) }
    def route?(method:)
      Rails.application.routes.recognize_path(yield, method:)
      true
    rescue NoMethodError, ActionController::RoutingError
      false
    end
  end
end
