require "test_helper"

class BulkDestroyTest < ActionDispatch::IntegrationTest
  test "index shows the delete selected button and a checkbox for each record" do
    get madmin_posts_path

    assert_select "form#bulk_destroy[action=?]", bulk_destroy_madmin_posts_path
    assert_select "input[type=checkbox][name='ids[]'][form=bulk_destroy]", count: Post.count
    assert_select "input[name='ids[]'][value=?]", posts(:one).id.to_s
  end

  test "delete selected keeps the index scope, search and filters" do
    get madmin_posts_path(scope: "recent", q: "My", filters: [{column: "title", operator: "contains", value: "String"}])

    assert_select "form#bulk_destroy" do
      assert_select "input[type=hidden][name=scope][value=recent]"
      assert_select "input[type=hidden][name=q][value=My]"
      assert_select "input[type=hidden][name='filters[][column]'][value=title]"
    end
  end

  test "index passes the delete selected confirmation with a count" do
    get madmin_posts_path

    form = css_select("form#bulk_destroy").first
    confirm = JSON.parse(form["data-bulk-destroy-confirm-value"])
    assert_equal "Are you sure you want to delete %{count} records?", confirm["other"]
  end

  test "index hides the delete selected button without the bulk destroy route" do
    get madmin_comments_path

    assert_select "form#bulk_destroy", count: 0
    assert_select "input[name='ids[]']", count: 0
  end

  test "bulk destroy without ids deletes nothing and redirects to the index" do
    assert_no_difference "Post.count" do
      delete bulk_destroy_madmin_posts_path
    end

    assert_response :see_other
    assert_redirected_to madmin_posts_path
    assert_nil flash[:alert]
  end

  test "bulk destroy deletes the selected records and keeps the rest" do
    kept = Post.create!(user: users(:one), title: "Kept")

    assert_difference "Post.count", -2 do
      delete bulk_destroy_madmin_posts_path, params: {ids: [posts(:one).id, posts(:two).id]}
    end

    assert_redirected_to madmin_posts_path
    assert Post.exists?(kept.id)
    assert_equal "2 records deleted", flash[:notice]
  end

  test "bulk destroy keeps going when a record can't be deleted" do
    posts(:one).published!

    assert_difference "Post.count", -1 do
      delete bulk_destroy_madmin_posts_path, params: {ids: [posts(:one).id, posts(:two).id]}
    end

    assert Post.exists?(posts(:one).id)
    assert_equal "1 record could not be deleted", flash[:alert]
  end

  test "bulk destroy keeps going when other records depend on one" do
    assert_difference "User.count", -1 do
      delete bulk_destroy_madmin_users_path, params: {ids: [users(:one).id, users(:two).id]}
    end

    assert User.exists?(users(:one).id)
    assert_redirected_to madmin_users_path
    assert_equal "1 record could not be deleted", flash[:alert]
  end

  test "bulk destroy skips records outside the index scope" do
    posts(:one).update_columns(created_at: 1.month.ago)

    assert_difference "Post.count", -1 do
      delete bulk_destroy_madmin_posts_path, params: {scope: "recent", ids: [posts(:one).id, posts(:two).id]}
    end

    assert Post.exists?(posts(:one).id)
  end
end
