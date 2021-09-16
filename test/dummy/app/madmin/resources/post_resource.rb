class PostResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :title
  attribute :comments_count, form: false
  attribute :metadata
  attribute :created_at, form: false
  attribute :updated_at, form: false
  attribute :body, index: false
  attribute :image, index: false
  attribute :attachments, index: false

  # Associations
  attribute :versions
  attribute :user
  attribute :comments

  # Uncomment this to customize the display name of records in the admin area.
  # def self.display_name(record)
  #   record.name
  # end

  # Uncomment this to customize the default sort column and direction.
  # def self.default_sort_column
  #   "created_at"
  # end
  #
  # def self.default_sort_direction
  #   "desc"
  # end
end
