module Madmin
  class BaseController < ActionController::Base
    include ::ActiveStorage::SetCurrent if defined?(::ActiveStorage)

    if Gem::Version.new(Pagy::VERSION) >= Gem::Version.new("43.0.0.rc")
      include Pagy::Method
    else
      include Pagy::Backend
    end

    protect_from_forgery with: :exception
  end
end
