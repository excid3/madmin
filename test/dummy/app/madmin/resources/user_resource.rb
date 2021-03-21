class UserResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :first_name
  attribute :last_name
  attribute :birthday
  attribute :created_at, form: false
  attribute :updated_at, form: false
  attribute :virtual_attribute, index: false
  attribute :avatar, index: false

  # Associations
  attribute :posts, :nested_has_many, skip: %I[enum attachments]
  attribute :comments
  attribute :habtms
end
