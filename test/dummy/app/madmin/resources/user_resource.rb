class UserResource < Madmin::Resource
  # Display scopes as filters (these cannot take arguments)
  scope :active
  scope :inactive

  attribute :id
  attribute :name, :string
  attribute :created_at
  attribute :updated_at
end
