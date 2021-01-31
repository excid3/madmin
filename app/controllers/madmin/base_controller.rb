module Madmin
  class BaseController < ActionController::Base
    include Pagy::Backend

    protect_from_forgery with: :exception

    # Loads all the models for the sidebar
    before_action do
      Rails.application.eager_load!
    end
  end
end
