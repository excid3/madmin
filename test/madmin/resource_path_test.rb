require "test_helper"

class ResourcePathTest < ActiveSupport::TestCase
  test "resource has an index path" do
    assert_equal "/madmin/posts", PostResource.index_path
  end

  test "resource has an index path with query params if given any arguments" do
    assert_equal "/madmin/posts?q=post&t=test", PostResource.index_path(q: "post", t: "test")
  end

  test "resource has a new path" do
    assert_equal "/madmin/posts/new", PostResource.new_path
  end

  test "resource has a show path" do
    post = posts(:one)
    assert_equal "/madmin/posts/#{post.id}", PostResource.show_path(post.id)
  end

  test "resource has an edit path" do
    post = posts(:one)
    assert_equal "/madmin/posts/#{post.id}/edit", PostResource.edit_path(post.id)
  end

  test "resource has an index path for non-model resource" do
    assert_equal "/madmin/action_text/rich_texts", ActionText::RichTextResource.index_path
  end
end
