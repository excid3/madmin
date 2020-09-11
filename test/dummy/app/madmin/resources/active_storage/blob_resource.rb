class ActiveStorage::BlobResource < Madmin::Resource
  # Attributes
  attribute :id
  attribute :key
  attribute :filename
  attribute :content_type
  attribute :metadata
  attribute :byte_size
  attribute :checksum
  attribute :created_at

  # Associations
  attribute :preview_image_attachment
  attribute :preview_image_blob
  attribute :attachments
end
