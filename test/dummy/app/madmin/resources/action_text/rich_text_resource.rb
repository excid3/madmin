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

  # Uncomment this to customize the display name of records in the admin area.
  # def self.display_name(record)
  #   record.name
  # end
end
