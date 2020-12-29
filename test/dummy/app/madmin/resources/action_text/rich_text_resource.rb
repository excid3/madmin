class ActionText::RichTextResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :name
  attribute :body
  attribute :created_at, form: false
  attribute :updated_at, form: false
  attribute :embeds, index: false

  # Associations
  attribute :record
end
