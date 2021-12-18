class PostResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :title, field: CustomField
  attribute :comments_count, form: false
  attribute :metadata
  attribute :created_at, form: false
  attribute :updated_at, form: false
  attribute :body, index: false
  attribute :image, index: false
  attribute :attachments, index: false
  attribute :state, index: false # Enum example

  attribute :user_id

  # Associations
  attribute :versions, form: false
  attribute :user
  attribute :comments

  # Scopes
  scope :recent

  # Uncomment this to customize the display name of records in the admin area.
  # def self.display_name(record)
  #   record.name
  # end

  # Uncomment this to customize the default sort column and direction.
  def self.default_sort_column
    "title"
  end

  def self.default_sort_direction
    "asc"
  end
end
