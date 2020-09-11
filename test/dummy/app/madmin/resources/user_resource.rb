class UserResource < Madmin::Resource
  # Attributes
  attribute :id
  attribute :first_name
  attribute :last_name
  attribute :birthday
  attribute :created_at
  attribute :updated_at
  attribute :virtual_attribute

  # Associations
  attribute :posts
  attribute :comments
end
