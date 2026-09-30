class User::ProfileResource < Madmin::Resource
  attribute :id, form: false
  attribute :bio
  attribute :website
  attribute :created_at, form: false
  attribute :updated_at, form: false

  attribute :user

  def self.display_name(record)
    "Profile ##{record.id}"
  end
end
