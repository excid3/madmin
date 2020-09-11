class ActiveStorage::AttachmentResource < Madmin::Resource
  # Attributes
  attribute :id
  attribute :name
  attribute :created_at

  # Associations
  attribute :record
  attribute :blob
end
