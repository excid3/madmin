class UserResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :name, :string, form: :false
  attribute :first_name
  attribute :last_name
  attribute :birthday
  attribute :ssn
  attribute :token, index: false
  attribute :created_at, form: false
  attribute :updated_at, form: false
  attribute :virtual_attribute, index: false
  attribute :password, index: false, show: false
  attribute :password_confirmation, index: false, show: false
  attribute :language
  attribute :notifications
  attribute :weekly_email
  attribute :monthly_newsletter
  attribute :avatar, index: false
  attribute :something, :string, index: false, form: false

  # Associations
  attribute :posts, :nested_has_many, skip: %I[attachments]
  attribute :comments
  attribute :habtms

  # Uncomment this to customize the display name of records in the admin area.
  def self.display_name(record)
    "#{record.first_name} #{record.last_name}"
  end

  # Uncomment this to customize the default sort column and direction.
  # def self.default_sort_column
  #   "created_at"
  # end
  #
  # def self.default_sort_direction
  #   "desc"
  # end
end
