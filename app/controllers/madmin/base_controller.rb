module Madmin
  class BaseController < ActionController::Base
    include ::ActiveStorage::SetCurrent if defined?(::ActiveStorage)
    include Pagy::Backend

    protect_from_forgery with: :exception
  end
end
