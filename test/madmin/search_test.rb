require "test_helper"

class SearchTest < ActiveSupport::TestCase
  test "generates query" do
    results = Madmin::Search.new(User.all, UserResource, "chris").run
    assert_equal users(:one), results.first
  end

  test "returns empty relation when no results found" do
    assert_empty Madmin::Search.new(User.all, UserResource, "nothing").run
  end
end
