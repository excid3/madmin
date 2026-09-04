require "test_helper"

class PostsResourceTest < ActionDispatch::IntegrationTest
  test "index renders collection_action blocks" do
    get madmin_posts_path
    assert_response :success
    assert_select "a[href=?]", madmin_posts_path(format: :csv), text: "Export CSV"
  end

  test "collection_action blocks render before the New link" do
    get madmin_posts_path
    assert_response :success

    # Both the collection action link and the New link should be present in the actions div
    assert_select ".actions" do
      assert_select "a", text: "Export CSV"
      assert_select "a", text: /New/
    end
  end

  test "index renders member actions with collection: true alongside the view and edit links" do
    get madmin_posts_path
    assert_response :success

    assert_select "tbody tr td:last-child" do
      assert_select "a", text: "View"
      assert_select "a", text: "Edit"
      assert_select "a", text: "Preview"
    end
  end

  test "index does not render member actions without collection: true" do
    get madmin_posts_path
    assert_response :success

    assert_select "tbody form", text: /Publish/, count: 0
  end

  test "show renders all member actions" do
    get madmin_post_path(posts(:one))
    assert_response :success

    assert_select ".actions" do
      assert_select "a", text: "Preview"
    end
  end

  test "erb pages with friendly_name.pluralize and localize setting" do
    I18n.reload!
    I18n.enforce_available_locales = false
    I18n.backend.store_translations :"zh-CN", activerecord: {
      models: {
        post: "文章"
      }
    }
    I18n.with_locale(:en) do
      get madmin_post_path(posts(:one))
      assert_response :success
      assert_select ".header>h1>a", text: "Posts"

      get madmin_user_path(users(:one))
      assert_response :success
      assert_select ".header>h1>a", text: "Users"
    end

    I18n.with_locale(:"zh-CN") do
      get madmin_post_path(posts(:one))
      assert_response :success
      assert_select ".header>h1>a", text: "文章"

      get madmin_user_path(users(:one))
      assert_response :success
      assert_select ".header>h1>a", text: "User"
    end
  ensure
    I18n.enforce_available_locales = true
  end

  test "menu with localize setting" do
    I18n.reload!
    I18n.enforce_available_locales = false
    I18n.backend.store_translations :en, {activerecord: {
      models: {
        post: {
          one: "Post",
          other: "Posts"
        }
      }
    }}
    I18n.backend.store_translations :"zh-CN", {activerecord: {
                                                 models: {
                                                   post: "文章"
                                                 }
                                               },
    madmin: {
      navigation: {
        user: "用户"
      }
    }}

    I18n.with_locale(:en) do
      get madmin_post_path(posts(:one))
      assert_response :success
      assert_select "nav a[href=?]", madmin_posts_path, text: "Posts"
      assert_select "nav a[href=?]", madmin_users_path, text: "Users"
    end

    I18n.with_locale(:"zh-CN") do
      get madmin_post_path(posts(:one))
      assert_response :success
      assert_select "nav a[href=?]", madmin_posts_path, text: "文章"
      assert_select "nav a[href=?]", madmin_users_path, text: "用户"
    end
  ensure
    I18n.enforce_available_locales = true
  end
end
