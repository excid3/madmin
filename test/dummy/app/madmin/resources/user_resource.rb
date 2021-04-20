class UserResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :first_name
  attribute :last_name
  attribute :birthday
  attribute :token, index: false
  attribute :created_at, form: false
  attribute :updated_at, form: false
  attribute :virtual_attribute, index: false
  attribute :password, index: false, show: false
  attribute :password_confirmation, index: false, show: false
  attribute :avatar, index: false

  # Associations
  attribute :posts, :nested_has_many, skip: %I[enum attachments]
  attribute :comments
  attribute :habtms

  # Uncomment this to customize the display name of records in the admin area.
  def self.display_name(record)
    "#{record.first_name} #{record.last_name}"
  end
end
