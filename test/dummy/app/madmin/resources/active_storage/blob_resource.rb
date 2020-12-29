class ActiveStorage::BlobResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :key
  attribute :filename
  attribute :content_type
  attribute :metadata
  attribute :byte_size
  attribute :checksum
  attribute :created_at, form: false
  attribute :preview_image, index: false

  # Associations
  attribute :attachments
end
