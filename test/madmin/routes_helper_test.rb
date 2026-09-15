require "test_helper"

class RoutesHelperTest < ActionView::TestCase
  include Madmin::RoutesHelper

  test "route? returns true for an existing route and matching method" do
    assert route?(method: :get) { madmin_posts_path }
  end

  test "route? returns false when the method does not match the route" do
    assert_not route?(method: :delete) { madmin_posts_path }
  end

  test "route? returns false for an unrecognized path" do
    assert_not route?(method: :get) { "/does/not/exist" }
  end
end
