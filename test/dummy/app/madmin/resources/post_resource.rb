class PostResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :title
  attribute :body, index: false
  attribute :comments_count, form: false
  attribute :metadata
  attribute :image, index: false
  attribute :attachments, index: false
  attribute :created_at
  attribute :updated_at

  # Associations
  attribute :user
  attribute :comments

  scope :recent
end
