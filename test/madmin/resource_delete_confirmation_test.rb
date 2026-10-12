require "test_helper"

class ResourceDeleteConfirmationTest < ActiveSupport::TestCase
  test "defaults to the shared confirmation" do
    assert_equal "Are you sure?", PostResource.delete_confirmation(posts(:one))
  end

  test "uses the resource's own translation when there is one" do
    with_translations(madmin: {resources: {post: {confirmations: {delete: "Delete the post %{name}?"}}}}) do
      assert_equal "Delete the post Post ##{posts(:one).id}?", PostResource.delete_confirmation(posts(:one))
    end
  end

  test "passes resource and name to the shared translation" do
    with_translations(madmin: {confirmations: {delete: "Delete %{resource} %{name}?"}}) do
      assert_equal "Delete User Chris Oliver?", UserResource.delete_confirmation(users(:one))
    end
  end

  test "resource can override the confirmation" do
    assert_equal "Delete the comment by Chris Oliver?", CommentResource.delete_confirmation(comments(:one))
  end

  private

  def with_translations(translations)
    I18n.backend.send(:init_translations) unless I18n.backend.initialized?
    I18n.backend.store_translations(:en, translations)
    yield
  ensure
    I18n.backend.reload!
  end
end
