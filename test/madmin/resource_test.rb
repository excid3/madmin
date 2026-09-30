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
    assert_equal "Foo Bar Bah", FooBarBahResource.friendly_name
    assert_equal "Active Storage / Blob", ActiveStorage::BlobResource.friendly_name
  end

  test "friendly_plural_name" do
    assert_equal "Users", UserResource.friendly_plural_name
    assert_equal "Foo Bar Bahs", FooBarBahResource.friendly_plural_name
    assert_equal "Active Storage / Blobs", ActiveStorage::BlobResource.friendly_plural_name
  end

  test "friendly names use the model's translation" do
    with_translations(
      en: {activerecord: {models: {post: {one: "Article", other: "Articles"}, user: "Person", comment: {one: "Staff", other: "Staff"}}}},
      "zh-CN": {activerecord: {models: {post: "文章", "active_storage/blob": "文件"}}}
    ) do
      assert_equal "Article", PostResource.friendly_name
      assert_equal "Articles", PostResource.friendly_plural_name

      # A translation with no plural forms is pluralized by the locale's inflections
      assert_equal "Person", UserResource.friendly_name
      assert_equal "People", UserResource.friendly_plural_name

      # Explicit plural forms are used as written, even when they match the singular
      assert_equal "Staff", CommentResource.friendly_plural_name

      I18n.with_locale(:"zh-CN") do
        assert_equal "文章", PostResource.friendly_name
        assert_equal "文章", PostResource.friendly_plural_name
        assert_equal "文件", ActiveStorage::BlobResource.friendly_name

        # Untranslated models keep their default names
        assert_equal "User", UserResource.friendly_name
        assert_equal "Users", UserResource.friendly_plural_name
      end
    end
  end

  test "menu label is a string that follows the locale" do
    with_translations("zh-CN": {activerecord: {models: {post: "文章"}}}) do
      assert_equal "Posts", PostResource.menu_options[:label]
      assert_equal "Active Storage / Blobs", ActiveStorage::BlobResource.menu_options[:label]

      I18n.with_locale(:"zh-CN") do
        assert_equal "文章", PostResource.menu_options[:label]
      end
    end
  end

  test "menu lists a resource once after the locale changes" do
    with_translations("zh-CN": {activerecord: {models: {post: "文章"}}}) do
      assert_includes menu_labels, "Posts"

      I18n.with_locale(:"zh-CN") do
        labels = menu_labels
        assert_includes labels, "文章"
        assert_not_includes labels, "Posts"
      end

      labels = menu_labels
      assert_includes labels, "Posts"
      assert_not_includes labels, "文章"
    end
  ensure
    Madmin.menu.reset
  end

  test "custom menu label is kept" do
    UserResource.menu label: "Custom label"
    assert_equal "Custom label", UserResource.menu_options[:label]
    assert_includes menu_labels, "Custom label"
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

  private

  def menu_labels
    labels = []
    Madmin.menu.render { |item| labels.push(item.label, *item.items.map(&:label)) }
    labels
  end

  def with_translations(translations)
    enforce, I18n.enforce_available_locales = I18n.enforce_available_locales, false
    translations.each { |locale, data| I18n.backend.store_translations(locale, data) }
    yield
  ensure
    I18n.enforce_available_locales = enforce
    I18n.reload!
  end
end
