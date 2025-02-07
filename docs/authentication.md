# Authenticating Madmin

There are a few different ways of adding authentication to Madmin.

### before_action

In `app/controllers/madmin/application_controller.rb`, there is a placeholder `before_action` that can be used for authenticating requests.

```ruby
module Madmin
  class ApplicationController < Madmin::BaseController
    include Rails.application.routes.url_helpers

    before_action :authenticate_admin_user

    def authenticate_admin_user
      # TODO: Add your authentication logic here

      # For example, with Rails 8 authentication
      # redirect_to "/", alert: "Not authorized." unless authenticated? && Current.user.admin?

      # Or with Devise
      # redirect_to "/", alert: "Not authorized." unless current_user&.admin?
    end
  end
end
```

### Devise Routes

Wrap the madmin routes in an `authenticated` or `authenticate` block:

```
authenticated :user, lambda { |u| u.admin? } do
  namespace :madmin do
  end
end
```

We recommend using `authenticated` as the `/madmin` route will 404 for any non-admins and reduces malicious attempts to get into your admin area.

### HTTP Basic Authentication

If you want to use HTTP Basic Authentication, you can use this in your
`Madmin::ApplicationController`:

```ruby
module Madmin
  class ApplicationController < Madmin::BaseController
    http_basic_authenticate_with(
      name: ENV['ADMIN_USERNAME'] || Rails.application.credentials.admin_username,
      password: ENV['ADMIN_PASSWORD'] || Rails.application.credentials.admin_password
    )
  end
end
```

This will use ENV vars (if defined) or fallback to the Rails credentials for admin username and password.

## Testing Authentication

We recommend writing an integration test to ensure only admins have access to Madmin. Something like this (assuming you have fixtures for regular users and admins).

```ruby
require "test_helper"

class MadminTest < ActionDispatch::IntegrationTest
  test "guests cannot access madmin" do
    get madmin_path
    assert_response :unauthorized
  end

  test "regular users cannot access madmin" do
    sign_in users(:regular)
    get madmin_path
    assert_response :unauthorized
  end

  test "admins can access madmin" do
    sign_in users(:admin)
    get madmin_path
    assert_response :success
  end
end
```
