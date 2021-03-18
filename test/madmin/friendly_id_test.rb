require "test_helper"

class FriendlyIdTest < ActiveSupport::TestCase
  test "resource can check for friendly_id functionality" do
    assert PostResource.friendly_model?
    refute UserResource.friendly_model?
  end

  test "can find models with friendly_id" do
    post = posts(:one)
    # Make sure we're looking up by something other than the ID
    assert_not_equal post.id, post.to_param
    assert_equal post, PostResource.model_find(post.title)
  end

  test "generates urls with friendly_id slugs" do
    post = posts(:one)
    assert_equal "/madmin/posts/#{post.title}", PostResource.show_path(post)
    assert_equal "/madmin/posts/#{post.title}/edit", PostResource.edit_path(post)
  end
end
