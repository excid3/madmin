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
  resources :users
  resources :comments
  resources :posts do
    member do
      patch :draft
      patch :publish
      patch :archive
    end
  end
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

  root to: "dashboard#show"
end
