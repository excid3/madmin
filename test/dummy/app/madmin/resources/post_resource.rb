class PostResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :title
  attribute :body, index: false
  attribute :image, index: false
  attribute :attachments, index: false
  attribute :enum
  attribute :tags
  attribute :ratings

  scope :recent
end
