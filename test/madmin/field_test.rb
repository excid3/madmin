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
end
