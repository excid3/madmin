class PaperTrail::VersionResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :event
  attribute :whodunnit
  attribute :object
  attribute :created_at, form: false
  attribute :object_changes

  # Associations
  attribute :item

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
