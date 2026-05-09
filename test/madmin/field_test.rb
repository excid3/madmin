require "test_helper"

class Madmin::FieldTest < ActiveSupport::TestCase
  test "required?" do
    assert PostResource.attributes[:title].field.required?
    refute PostResource.attributes[:id].field.required?
  end

  test "searchable?" do
    assert UserResource.attributes[:first_name].field.searchable?
    refute UserResource.attributes[:created_at].field.searchable?
  end

  test "visible?" do
    assert UserResource.attributes[:name].field.visible?(:index)
  end

  test "label" do
    assert_equal "First Name", UserResource.attributes[:first_name].field.label
  end

  test "label with custom option" do
    field = Madmin::Fields::String.new(
      attribute_name: :some_attribute,
      model: User,
      resource: UserResource,
      options: ActiveSupport::OrderedOptions.new.merge(label: "Custom Label")
    )
    assert_equal "Custom Label", field.label
  end

  test "label with blank option" do
    field = Madmin::Fields::String.new(
      attribute_name: :some_attribute,
      model: User,
      resource: UserResource,
      options: ActiveSupport::OrderedOptions.new.merge(label: "")
    )
    assert_equal "Some Attribute", field.label
  end
end
