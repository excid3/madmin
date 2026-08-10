require "test_helper"

class FooBarBahResource < Madmin::Resource; end

class CollectionActionParentResource < Madmin::Resource
  collection_action { "parent_action" }
end

class CollectionActionChildResource < CollectionActionParentResource
  collection_action { "child_action" }
end

class ResourceTest < ActiveSupport::TestCase
  test "searchable_attributes" do
    searchable_attribute_names = UserResource.searchable_attributes.map(&:name)
    assert_includes searchable_attribute_names, :first_name
  end

  test "rich_text" do
    assert_equal :rich_text, PostResource.attributes[:body].type
  end

  test "friendly_name" do
    assert_equal "User", UserResource.friendly_name
    assert_equal "Foo Bar Bah", FooBarBahResource.friendly_name
  end

  test "collection_actions defaults to empty array" do
    assert_equal [], Madmin::Resource.collection_actions
  end

  test "collection_action appends block to collection_actions" do
    assert_equal 1, CollectionActionParentResource.collection_actions.size
    assert_equal "parent_action", CollectionActionParentResource.collection_actions.first.call
  end

  test "subclass inherits parent collection_actions and can add its own" do
    assert_equal 2, CollectionActionChildResource.collection_actions.size
    assert_equal "parent_action", CollectionActionChildResource.collection_actions.first.call
    assert_equal "child_action", CollectionActionChildResource.collection_actions.last.call
  end

  test "child collection_actions do not leak to parent" do
    assert_equal 1, CollectionActionParentResource.collection_actions.size
  end
end
