require "test_helper"

class ReadonlyResourceTest < ActionDispatch::IntegrationTest
  test "resources are writable by default" do
    assert_not PostResource.readonly?
  end

  test "index hides new and edit links for readonly resources" do
    with_readonly(PostResource) do
      get madmin_posts_path
      assert_response :success
      assert_select "a[href=?]", new_madmin_post_path, count: 0
      assert_select "a[href=?]", edit_madmin_post_path(posts(:one)), count: 0
    end
  end

  test "show hides edit and delete buttons for readonly resources" do
    with_readonly(PostResource) do
      get madmin_post_path(posts(:one))
      assert_response :success
      assert_select "a[href=?]", edit_madmin_post_path(posts(:one)), count: 0
      assert_select "form[action=?]", madmin_post_path(posts(:one)), count: 0
    end
  end

  test "new and create redirect for readonly resources" do
    with_readonly(PostResource) do
      get new_madmin_post_path
      assert_redirected_to madmin_posts_path
      assert_equal "Post is read-only", flash[:alert]

      assert_no_difference "Post.count" do
        post madmin_posts_path, params: {post: {title: "Nope"}}
      end
      assert_redirected_to madmin_posts_path
    end
  end

  test "edit, update and destroy redirect for readonly resources" do
    with_readonly(PostResource) do
      get edit_madmin_post_path(posts(:one))
      assert_redirected_to madmin_posts_path

      put madmin_post_path(posts(:one)), params: {post: {title: "Nope"}}
      assert_redirected_to madmin_posts_path
      assert_not_equal "Nope", posts(:one).reload.title

      assert_no_difference "Post.count" do
        delete madmin_post_path(posts(:one))
      end
      assert_redirected_to madmin_posts_path
    end
  end

  private

  def with_readonly(resource_class)
    resource_class.singleton_class.define_method(:readonly?) { true }
    yield
  ensure
    resource_class.singleton_class.remove_method(:readonly?)
  end
end
