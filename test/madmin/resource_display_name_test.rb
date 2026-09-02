require "test_helper"

class ResourceDisplayNameTest < ActiveSupport::TestCase
  test "resource has a custom display name" do
    resource = users(:one)
    assert_equal "Chris Oliver", UserResource.display_name(resource)
  end

  test "resource uses default display name" do
    resource = posts(:one)
    assert_equal "Post ##{resource.id}", PostResource.display_name(resource)
  end

  test "resource use default display name with localize setting" do
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
        post: {
          one: "文章",
          other: "文章",
        }
      }
    }
    resource = posts(:one)
    I18n.with_locale(:en) do
      assert_equal "Post ##{resource.id}", PostResource.display_name(resource)
    end
    I18n.with_locale(:"zh-CN") do
      assert_equal "文章 ##{resource.id}", PostResource.display_name(resource)
    end
  ensure
    I18n.enforce_available_locales = true

  end
end
