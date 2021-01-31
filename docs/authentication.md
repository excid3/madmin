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
