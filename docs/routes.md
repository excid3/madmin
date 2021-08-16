# Routes
Routes should be under the namespace of madmin module.Like
namespace :madmin do
	namespace :user do
	  resources :connected_accounts
	end	
  end