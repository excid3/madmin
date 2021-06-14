Rails.application.routes.draw do
  namespace :madmin do
    namespace :paper_trail do
      resources :versions
    end
    namespace :active_storage do
      resources :variant_records
    end
    resources :numericals
    resources :habtms
    resources :teams
    root to: "dashboard#show"
    resources :users
    resources :comments
    resources :posts
    namespace :action_text do
      resources :rich_texts
    end
    namespace :user do
      resources :connected_accounts
    end
    namespace :active_storage do
      resources :blobs
    end
    namespace :active_storage do
      resources :attachments
    end
    namespace :action_mailbox do
      resources :inbound_emails
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: "home#index"
end
