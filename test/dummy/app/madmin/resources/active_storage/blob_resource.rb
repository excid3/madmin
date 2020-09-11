class ActiveStorage::BlobResource < Madmin::Resource
  attribute :id
  attribute :key
  attribute :filename
  attribute :content_type
  attribute :metadata
  attribute :byte_size
  attribute :checksum
  attribute :created_at
  attribute :updated_at
end
