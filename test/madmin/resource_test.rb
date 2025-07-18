require "test_helper"

class FooBarBahResource < Madmin::Resource; end

class ResourceTest < ActiveSupport::TestCase
  test "searchable_attributes" do
    searchable_attribute_names = UserResource.searchable_attributes.map(&:name)
    assert_includes searchable_attribute_names, :first_name
  end

  test "rich_text" do
    assert_equal :rich_text, PostResource.attributes[:body].type
  end

  test "friendly_name" do
    assert_equal "Users", UserResource.friendly_name
    assert_equal "Foo Bar Bahs", FooBarBahResource.friendly_name
  end
end
