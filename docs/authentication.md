# Authenticating Madmin

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
