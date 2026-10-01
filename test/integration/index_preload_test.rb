require "test_helper"

class IndexPreloadTest < ActionDispatch::IntegrationTest
  test "index loads associations once instead of once per row" do
    5.times { |i| Comment.create!(user: users(:one), commentable: posts(:two), body: "Comment #{i}") }

    queries = []
    callback = ->(*, payload) { queries << payload[:name] }
    ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
      get madmin_comments_path
    end

    assert_response :success
    assert_equal 1, queries.count("User Load")
    assert_equal 1, queries.count("Post Load")
  end
end
