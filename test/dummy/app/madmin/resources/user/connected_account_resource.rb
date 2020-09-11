class User::ConnectedAccountResource < Madmin::Resource
  # Attributes
  attribute :id
  attribute :service
  attribute :created_at
  attribute :updated_at

  # Associations
  attribute :user
end
