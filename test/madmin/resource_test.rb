require "test_helper"

class ResourceTest < ActiveSupport::TestCase
  test "searchable_attributes" do
    searchable_attribute_names = UserResource.searchable_attributes.map { |a| a[:name] }
    assert_includes searchable_attribute_names, :first_name
  end
end
