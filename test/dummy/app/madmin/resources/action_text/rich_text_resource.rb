class ActionText::RichTextResource < Madmin::Resource
  # Attributes
  attribute :id
  attribute :name
  attribute :body
  attribute :created_at
  attribute :updated_at

  # Associations
  attribute :record
  attribute :embeds_attachments
  attribute :embeds_blobs
end
