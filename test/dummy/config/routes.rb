Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :madmin do
    resources :comments
    resources :posts
    resources :users
    namespace :action_mailbox do
      resources :inbound_emails
    end
    namespace :user do
      resources :connected_accounts
    end
    namespace :action_text do
      resources :rich_texts
    end
    namespace :active_storage do
      resources :attachments
      resources :blobs
    end
  end

  root to: "home#index"
end
