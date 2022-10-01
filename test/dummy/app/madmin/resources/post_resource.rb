class PostResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :title, field: CustomField
  attribute :comments_count, form: false
  attribute :metadata
  attribute :created_at
  attribute :updated_at, form: false
  attribute :body, index: false
  attribute :image, index: false
  attribute :attachments, index: false
  attribute :state, index: false # Enum example

  attribute :user_id

  # Associations
  attribute :versions, form: false
  attribute :user
  attribute :comments

  # Scopes
  scope :recent

  member_action do
    unless @record.published?
      button_to "Publish", main_app.publish_madmin_post_path(@record), method: :patch, data: { turbo_confirm: "Are you sure?" }, class: "block bg-white hover:bg-gray-100 text-gray-800 font-semibold py-2 px-4 border border-gray-400 rounded shadow"
    end
  end


  member_action do
    unless @record.draft?
      button_to "Draft", main_app.draft_madmin_post_path(@record), method: :patch, data: { turbo_confirm: "Are you sure?" }, class: "block bg-white hover:bg-gray-100 text-gray-800 font-semibold py-2 px-4 border border-gray-400 rounded shadow"
    end
  end

  member_action do
    unless @record.archived?
      button_to "Archive", main_app.archive_madmin_post_path(@record), method: :patch, data: { turbo_confirm: "Are you sure?" }, class: "block bg-white hover:bg-gray-100 text-gray-800 font-semibold py-2 px-4 border border-gray-400 rounded shadow"
    end
  end

  # Uncomment this to customize the display name of records in the admin area.
  # def self.display_name(record)
  #   record.name
  # end

  # Uncomment this to customize the default sort column and direction.
  def self.default_sort_column
    "title"
  end

  def self.default_sort_direction
    "asc"
  end
end
