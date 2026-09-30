require "test_helper"

class ArrayFieldsTest < ActionDispatch::IntegrationTest
  setup do
    skip "Array columns are PostgreSQL only" unless Post.columns_hash["tags"].try(:array?)
    @post = posts(:one)
    @post.update!(tags: ["ruby", "rails"])
  end

  test "infers the array field" do
    assert_instance_of Madmin::Fields::Array, PostResource.attributes[:tags].field
  end

  test "shows the values separated by commas" do
    get madmin_post_path(@post)
    assert_select "td", text: "ruby, rails"

    get edit_madmin_post_path(@post)
    assert_select "input[name='post[tags]'][value=?]", "ruby, rails"
  end

  test "saves comma separated values as an array" do
    put madmin_post_path(@post), params: {post: {tags: "ruby, rails , ,hotwire"}}
    assert_response :redirect
    assert_equal ["ruby", "rails", "hotwire"], @post.reload.tags
  end

  test "saves blank as an empty array" do
    put madmin_post_path(@post), params: {post: {tags: ""}}
    assert_equal [], @post.reload.tags
  end

  test "filters by an included value" do
    posts(:two).update!(tags: ["hotwire"])

    get madmin_posts_path
    assert_select "#filters option[value=tags][data-filter-type=array]"

    get madmin_posts_path(filters: [{column: "tags", operator: "includes", value: "rails"}])
    assert_select ".filter-chip", text: /Tags\s+includes\s+rails/
    assert_select "tbody a[href=?]", madmin_post_path(@post)
    assert_select "tbody a[href=?]", madmin_post_path(posts(:two)), count: 0
  end
end
