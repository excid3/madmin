class ActionText::RichTextResource < Madmin::Resource
  # Attributes
  attribute :id
  attribute :name
  attribute :body
  attribute :created_at
  attribute :updated_at
  attribute :embeds

  # Associations
  attribute :record
end
