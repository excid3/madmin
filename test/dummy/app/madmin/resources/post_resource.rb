class PostResource < Madmin::Resource
  attribute :id
  attribute :user
  attribute :title
  attribute :body
  attribute :image
  attribute :created_at
  attribute :updated_at
end

