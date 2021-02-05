class PostResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :title
  attribute :comments_count, form: false
  attribute :metadata
  attribute :created_at, form: false
  attribute :updated_at, form: false
  attribute :body, index: false
  attribute :image, index: false
  attribute :attachments, index: false

  # Associations
  attribute :user
  attribute :comments

  scope :recent
end
