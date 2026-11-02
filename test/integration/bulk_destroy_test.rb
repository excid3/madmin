require "test_helper"

class BulkDestroyTest < ActionDispatch::IntegrationTest
  test "index has checkboxes and the bulk form when the route is drawn" do
    get madmin_posts_path(scope: "recent")

    assert_select "form#bulk-form[action=?]", bulk_destroy_madmin_posts_path
    assert_select "form#bulk-form input[type=hidden][name=scope][value=recent]"
    assert_select "td.bulk-select input[name='ids[]'][form=bulk-form]", Post.count
  end

  test "index has no checkboxes without the route" do
    get madmin_users_path

    assert_select "form#bulk-form", false
    assert_select ".bulk-select", false
  end

  test "deletes the selected records" do
    assert_difference "Post.count", -1 do
      delete bulk_destroy_madmin_posts_path, params: {ids: [posts(:one).id], scope: "recent"}
    end

    assert_response :see_other
    assert_redirected_to madmin_posts_path(scope: "recent")
    assert_equal "Deleted 1 record", flash[:notice]
    assert Post.exists?(posts(:two).id)
  end

  test "deletes nothing without ids" do
    assert_no_difference "Post.count" do
      delete bulk_destroy_madmin_posts_path
    end

    assert_redirected_to madmin_posts_path
  end

  test "all deletes every record matching the search" do
    other = Comment.create!(body: "Unrelated", user: users(:one), commentable: posts(:one))

    assert_difference "Comment.count", -2 do
      delete bulk_destroy_madmin_comments_path, params: {all: 1, q: "MyText"}
    end

    assert_redirected_to madmin_comments_path(q: "MyText")
    assert_equal "Deleted 2 records", flash[:notice]
    assert Comment.exists?(other.id)
  end

  test "all deletes every record matching the filters" do
    Comment.create!(body: "Unrelated", user: users(:one), commentable: posts(:one))
    filters = [{column: "body", operator: "eq", value: "Unrelated"}]

    delete bulk_destroy_madmin_comments_path, params: {all: 1, filters: filters}

    assert_redirected_to madmin_comments_path(filters: filters)
    assert_equal comments(:one, :two).sort_by(&:id), Comment.order(:id).to_a
  end

  test "skips records that can't be deleted and reports them" do
    posts(:one).published!

    assert_difference "Post.count", -1 do
      delete bulk_destroy_madmin_posts_path, params: {ids: Post.ids}
    end

    assert_equal "Deleted 1 record", flash[:notice]
    assert_equal "1 record could not be deleted", flash[:alert]
    assert Post.exists?(posts(:one).id)
  end
end
