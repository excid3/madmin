class PostResource < Madmin::Resource
  # Attributes
  attribute :id
  attribute :title
  attribute :comments_count
  attribute :metadata
  attribute :created_at
  attribute :updated_at
  attribute :body
  attribute :image
  attribute :attachments

  # Associations
  attribute :user
  attribute :comments
end
