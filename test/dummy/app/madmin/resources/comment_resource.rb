class CommentResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :body
  attribute :created_at, form: false
  attribute :updated_at, form: false

  # Associations
  attribute :user
  attribute :commentable, collection: -> { Post.all }
end
