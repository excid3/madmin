require "test_helper"

class FooBarBah < ApplicationRecord; end
class FooBarBahResource < Madmin::Resource; end

class CollectionActionParentResource < Madmin::Resource
  collection_action { "parent_action" }
end

class CollectionActionChildResource < CollectionActionParentResource
  collection_action { "child_action" }
end

class MemberActionParentResource < Madmin::Resource
  member_action { "parent_action" }
  member_action(collection: true) { "parent_collection_action" }
end

class MemberActionChildResource < MemberActionParentResource
  member_action { "child_action" }
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
    assert_equal "Foo bar bah", FooBarBahResource.friendly_name
  end

  test "friendly_name with localize setting" do
    I18n.enforce_available_locales = false

    I18n.backend.store_translations :en, activerecord: {
      models: {
        post: {
          one: "Post",
          other: "Posts"
        }
      }
    }
    I18n.backend.store_translations :"zh-CN", activerecord: {
      models: {
        post: "文章",
        "active_storage/attachment": "附件"
      }
    }

    I18n.with_locale(:en) do
      assert_equal "Post", PostResource.friendly_name
      assert_equal "Posts", PostResource.friendly_name(count: 2)
    end
    I18n.with_locale(:"zh-CN") do
      assert_equal "文章", PostResource.friendly_name
      assert_equal "文章", PostResource.friendly_name(count: 2)
      assert_equal "User", UserResource.friendly_name
      assert_equal "User", UserResource.friendly_name(count: 2)
      assert_equal "附件", ActiveStorage::AttachmentResource.friendly_name
    end
  ensure
    I18n.enforce_available_locales = true
  end

  test "default menu label" do
    assert_equal :"active_storage/blob", ActiveStorage::BlobResource.menu_options.dig(:label)
    assert_equal :post, PostResource.menu_options.dig(:label)
  end

  test "customize menu labal" do
    UserResource.menu label: "Custom label"
    assert_equal "Custom label", UserResource.menu_options.dig(:label)
  ensure
    UserResource.menu nil
    Madmin.menu.reset
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

  test "member_actions defaults to empty array" do
    assert_equal [], Madmin::Resource.member_actions
  end

  test "member_action defaults to collection: false" do
    action = MemberActionParentResource.member_actions.first
    refute_predicate action, :collection?
    assert_equal "parent_action", action.call
  end

  test "collection_member_actions only includes actions with collection: true" do
    actions = MemberActionParentResource.collection_member_actions
    assert_equal 1, actions.size
    assert_equal "parent_collection_action", actions.first.call
  end

  test "member actions can be converted to a block" do
    assert_equal "parent_action", instance_exec(&MemberActionParentResource.member_actions.first)
  end

  test "subclass inherits parent member_actions and can add its own" do
    assert_equal 3, MemberActionChildResource.member_actions.size
    assert_equal 2, MemberActionParentResource.member_actions.size
    assert_equal "child_action", MemberActionChildResource.member_actions.last.call
    assert_equal 1, MemberActionChildResource.collection_member_actions.size
  end

  test "scope_label humanizes the scope name by default" do
    assert_equal "Recently updated", PostResource.scope_label(:recently_updated)
  end

  test "scope_label uses a resource-specific translation when defined" do
    I18n.backend.store_translations(:en, madmin: {scopes: {post: {recent: "Fresh"}}})
    assert_equal "Fresh", PostResource.scope_label(:recent)
  ensure
    I18n.reload!
  end

  test "scope_label falls back to a shared scope translation" do
    I18n.backend.store_translations(:en, madmin: {scopes: {recent: "Latest"}})
    assert_equal "Latest", PostResource.scope_label(:recent)
  ensure
    I18n.reload!
  end

  test "scope_label can be overridden per resource" do
    resource = Class.new(PostResource) do
      def self.scope_label(name)
        name.to_s.upcase
      end
    end

    assert_equal "RECENT", resource.scope_label(:recent)
  end
end
