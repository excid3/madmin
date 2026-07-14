require "test_helper"

class AssetsTest < ActionDispatch::IntegrationTest
  test "madmin renders resolved asset urls" do
    get madmin_root_path

    assert_response :success
    assert_match %r{"application": "/assets/[^"]+\.js"}, response.body
    assert_match %r{"@hotwired/turbo-rails": "/assets/[^"]+\.js"}, response.body
  end
end
