require "test_helper"

class ResourceDisplayNameTest < ActiveSupport::TestCase
  test "resource has a custom display name" do
    resource = users(:one)

    assert_equal "Chris Oliver", UserResource.display_name(resource)
  end

  test "resource uses default display name" do
    resource = posts(:one)

    assert_equal "Post ##{resource.id}", PostResource.display_name(resource)
  end
end
