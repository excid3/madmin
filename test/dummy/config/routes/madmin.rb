# Below are the routes for madmin
namespace :madmin do
  namespace :action_mailbox do
    resources :inbound_emails
  end
  namespace :action_text do
    resources :rich_texts
  end
  namespace :action_text do
    resources :encrypted_rich_texts
  end
  resources :comments
  resources :habtms
  resources :numericals
  resources :posts
  resources :users
  namespace :user do
    resources :connected_accounts
  end
  namespace :active_storage do
    resources :attachments
  end
  namespace :active_storage do
    resources :blobs
  end
  namespace :active_record do
    namespace :session_store do
      resources :sessions
    end
  end
  namespace :active_storage do
    resources :variant_records
  end
  namespace :paper_trail do
    resources :versions
  end
  root to: "dashboard#show"
end
