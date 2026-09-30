module Madmin
  class BaseController < ActionController::Base
    include ::ActiveStorage::SetCurrent if defined?(::ActiveStorage)

    include Madmin::Pagination

    protect_from_forgery with: :exception

    ActiveSupport.run_load_hooks(:madmin_base_controller, self)
  end
end
