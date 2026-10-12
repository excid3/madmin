require "test_helper"

class ResourceDeleteConfirmationTest < ActiveSupport::TestCase
  test "defaults to the shared confirmation" do
    assert_equal "Are you sure?", PostResource.delete_confirmation(posts(:one))
  end

  test "uses the resource's own translation when there is one" do
    habtm = Habtm.create!(name: "Tags")
    assert_equal "Delete the habtm Habtm ##{habtm.id}?", HabtmResource.delete_confirmation(habtm)
  end
end
