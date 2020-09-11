class ActiveStorage::AttachmentResource < Madmin::Resource
  attribute :id
  attribute :name
  attribute :record_type
  attribute :record_id
  attribute :blob_id
  attribute :created_at
  attribute :updated_at
end
