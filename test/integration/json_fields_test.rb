require "test_helper"

class JsonFieldsTest < ActionDispatch::IntegrationTest
  setup { @post = posts(:one) }

  test "parses the submitted JSON" do
    put madmin_post_path(@post), params: {post: {title: "Updated", metadata: '{"tags": ["ruby", "rails"], "priority": 1}'}}

    assert_response :redirect
    assert_equal "Updated", @post.reload.title
    assert_equal({"tags" => %w[ruby rails], "priority" => 1}, @post.metadata)
  end

  test "parses JSON when creating a record" do
    assert_difference "Post.count" do
      post madmin_posts_path, params: {post: {title: "New", user_id: users(:one).id, metadata: '{"draft": true}'}}
    end

    assert_equal({"draft" => true}, Post.last.metadata)
  end

  test "saves a blank field as nil" do
    @post.update!(metadata: {"draft" => true})

    put madmin_post_path(@post), params: {post: {metadata: ""}}

    assert_redirected_to madmin_post_path(@post)
    assert_nil @post.reload.metadata
  end

  test "edit form shows the value as JSON" do
    @post.update!(metadata: {"tags" => ["ruby"]})

    get edit_madmin_post_path(@post)

    assert_select "textarea[name=?]", "post[metadata]" do |textarea|
      assert_equal({"tags" => ["ruby"]}, JSON.parse(textarea.text))
    end
  end

  test "saving the edit form unchanged keeps the value" do
    @post.update!(metadata: {"tags" => ["ruby"]})

    get edit_madmin_post_path(@post)
    put madmin_post_path(@post), params: {post: {metadata: css_select("textarea[name='post[metadata]']").text}}

    assert_equal({"tags" => ["ruby"]}, @post.reload.metadata)
  end

  test "invalid JSON re-renders the form without saving" do
    @post.update!(metadata: {"tags" => ["ruby"]})
    invalid = '{"tags": ["ruby"'

    put madmin_post_path(@post), params: {post: {title: "Updated", metadata: invalid}}

    assert_response :unprocessable_entity
    assert_select ".alert-danger li", text: "Metadata is invalid"
    assert_select "textarea[name=?]", "post[metadata]", text: invalid
    assert_select "input[name=?][value=?]", "post[title]", "Updated"
    assert_equal "MyString", @post.reload.title
    assert_equal({"tags" => ["ruby"]}, @post.metadata)
  end

  test "text saved before JSON was parsed can be fixed by saving the form" do
    @post.update!(metadata: '{"tags": ["ruby"]}')

    get edit_madmin_post_path(@post)
    put madmin_post_path(@post), params: {post: {metadata: css_select("textarea[name='post[metadata]']").text}}

    assert_equal({"tags" => ["ruby"]}, @post.reload.metadata)
  end

  test "show page renders the value as JSON" do
    @post.update!(metadata: {"tags" => ["ruby"]})

    get madmin_post_path(@post)

    assert_select "pre" do |pre|
      assert_equal({"tags" => ["ruby"]}, JSON.parse(pre.text))
    end
  end

  test "polymorphic values are located from the submitted global id" do
    comment = Comment.create!(commentable: @post, user: users(:one), body: "Hi")

    put madmin_comment_path(comment), params: {comment: {commentable: {type: "polymorphic", value: posts(:two).to_global_id.to_s}}}

    assert_equal posts(:two), comment.reload.commentable
  end

  test "invalid JSON does not create a record" do
    assert_no_difference "Post.count" do
      post madmin_posts_path, params: {post: {title: "New", user_id: users(:one).id, metadata: "nope"}}
    end

    assert_response :unprocessable_entity
    assert_select "textarea[name=?]", "post[metadata]", text: "nope"
  end
end
