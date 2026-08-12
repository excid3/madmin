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
end
