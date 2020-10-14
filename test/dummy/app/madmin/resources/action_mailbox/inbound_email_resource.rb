class ActionMailbox::InboundEmailResource < Madmin::Resource
  # Attributes
  attribute :id
  attribute :status
  attribute :message_id
  attribute :message_checksum
  attribute :created_at
  attribute :updated_at
  attribute :raw_email

  # Associations
end
