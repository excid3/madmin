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
