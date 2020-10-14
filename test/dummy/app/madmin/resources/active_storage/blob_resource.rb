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
  attribute :preview_image

  # Associations
  attribute :attachments
end
