class PostResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :title
  attribute :body, index: false
  attribute :image, index: false
  attribute :attachments, index: false
  attribute :enum

  scope :recent
end
