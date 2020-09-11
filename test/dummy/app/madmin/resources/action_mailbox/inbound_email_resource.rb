class ActionMailbox::InboundEmailResource < Madmin::Resource
  attribute :id
  attribute :status
  attribute :message_id
  attribute :message_checksum
  attribute :created_at
  attribute :updated_at
end
