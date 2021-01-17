class HabtmResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :name

  # Associations
  attribute :users
end
