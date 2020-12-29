class ActionMailbox::InboundEmailResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :status
  attribute :message_id
  attribute :message_checksum
  attribute :created_at, form: false
  attribute :updated_at, form: false
  attribute :raw_email, index: false

  # Associations
end
