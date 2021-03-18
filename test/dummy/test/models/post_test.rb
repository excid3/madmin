require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "supports friendly-id" do
    assert PostResource.friendly_model?
    refute UserResource.friendly_model?

    post = posts(:one)
    assert_equal post, PostResource.model_find(post.title)

    assert_equal "/madmin/posts/#{post.title}", PostResource.show_path(post)
    assert_equal "/madmin/posts/#{post.title}/edit", PostResource.edit_path(post)
  end
end
