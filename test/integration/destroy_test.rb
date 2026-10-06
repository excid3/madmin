require "test_helper"

class DestroyTest < ActionDispatch::IntegrationTest
  test "destroy shows the model's errors when the record can't be deleted" do
    posts(:one).published!

    assert_no_difference "Post.count" do
      delete madmin_post_path(posts(:one))
    end

    assert_response :see_other
    assert_redirected_to madmin_posts_path
    assert_equal "Published posts can't be deleted. Unpublish it first.", flash[:alert]
  end

  test "destroy redirects back to the referring page when the record can't be deleted" do
    posts(:one).published!

    delete madmin_post_path(posts(:one)), headers: {"HTTP_REFERER" => madmin_post_url(posts(:one))}

    assert_response :see_other
    assert_redirected_to madmin_post_url(posts(:one))
  end

  test "destroy shows a generic alert when the record has no errors" do
    posts(:one).archived!

    assert_no_difference "Post.count" do
      delete madmin_post_path(posts(:one))
    end

    assert_redirected_to madmin_posts_path
    assert_equal "Post could not be deleted", flash[:alert]
  end

  test "destroy shows an alert when other records restrict the deletion" do
    assert_no_difference "User.count" do
      delete madmin_user_path(users(:one))
    end

    assert_response :see_other
    assert_redirected_to madmin_users_path
    assert_equal "User could not be deleted because other records depend on it", flash[:alert]
  end

  test "destroy deletes the record and redirects to the index" do
    assert_difference "Post.count", -1 do
      delete madmin_post_path(posts(:one))
    end

    assert_response :see_other
    assert_redirected_to madmin_posts_path
    assert_nil flash[:alert]
    assert_equal "Post deleted", flash[:notice]
  end
end
