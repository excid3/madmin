# Routes
Routes should be under the namespace of madmin module:

```ruby
namespace :madmin do
  resources :posts
  namespace :user do
    resources :connected_accounts
  end
end
```

The namespace has to stay `madmin`: Madmin's controllers live in the `Madmin` module and its path helpers are prefixed with `madmin_`. To serve the admin at a different URL, change the `path` instead:

```ruby
namespace :madmin, path: "admin" do
  resources :posts
end
```

This serves `/admin/posts` while the controllers and helpers stay the same.
