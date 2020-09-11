class CommentResource < Madmin::Resource
  # Attributes
  attribute :id
  attribute :body
  attribute :created_at
  attribute :updated_at

  # Associations
  attribute :user
  attribute :commentable
end
