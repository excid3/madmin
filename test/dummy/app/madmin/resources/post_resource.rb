class PostResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :title
  attribute :body, index: false
  attribute :comments_count, form: false
  attribute :metadata
  attribute :image, index: false
  attribute :attachments, index: false
  attribute :created_at, form: false
  attribute :updated_at, form: false

  # Associations
  attribute :user
  attribute :comments
end
