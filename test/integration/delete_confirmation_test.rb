require "test_helper"

class DeleteConfirmationTest < ActionDispatch::IntegrationTest
  test "show confirms with the shared message by default" do
    get madmin_post_path(posts(:one))
    assert_select "form[action=?] input[type=submit][data-turbo-confirm=?]", madmin_post_path(posts(:one)), "Are you sure?"
  end

  test "show confirms with the resource's message" do
    get madmin_comment_path(comments(:one))
    assert_select "form[action=?] input[type=submit][data-turbo-confirm=?]", madmin_comment_path(comments(:one)), "Delete the comment by Chris Oliver?"
  end

  test "show skips the confirmation when the resource returns nil" do
    get madmin_numerical_path(numericals(:one))
    assert_select "form[action=?] input[type=submit]", madmin_numerical_path(numericals(:one)), count: 1
    assert_select "form[action=?] input[type=submit][data-turbo-confirm]", madmin_numerical_path(numericals(:one)), count: 0
  end
end
