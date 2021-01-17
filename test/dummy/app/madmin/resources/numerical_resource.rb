class NumericalResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :decimal
  attribute :float
  attribute :created_at, form: false
  attribute :updated_at, form: false

  # Associations
end
