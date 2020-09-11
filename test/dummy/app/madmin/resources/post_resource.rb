class PostResource < Madmin::Resource
  # Attributes
  attribute :id
  attribute :title
  attribute :comments_count
  attribute :metadata
  attribute :created_at
  attribute :updated_at

  # Associations
  attribute :user
  attribute :comments
  attribute :rich_text_body
  attribute :image_attachment
  attribute :image_blob
  attribute :attachments_attachments
  attribute :attachments_blobs
end
