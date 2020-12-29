class User::ConnectedAccountResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :service
  attribute :created_at, form: false
  attribute :updated_at, form: false

  # Associations
  attribute :user
end
