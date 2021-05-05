class PostResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :title
  attribute :comments_count, form: false
  attribute :metadata
  attribute :enum
  attribute :created_at, form: false
  attribute :updated_at, form: false
  attribute :body, index: false
  attribute :image, index: false
  attribute :attachments, index: false

  # Associations
  attribute :user
  attribute :comments, form: false

  # Scopes
  scope :recent

  # Uncomment this to customize the display name of records in the admin area.
  # def self.display_name(record)
  #   record.name
  # end

  def self.default_sort_column
    "title"
  end

  def self.default_sort_direction
    "asc"
  end
end
