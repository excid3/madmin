require "test_helper"

class JsonFieldsTest < ActionDispatch::IntegrationTest
  test "can update model with JSON field" do
    post = posts(:one)
    json_metadata = '{"tags": ["ruby", "rails"], "priority": "high"}'

    put madmin_post_path(post), params: {
      post: {
        title: "Updated Post",
        metadata: json_metadata
      }
    }

    assert_response :redirect

    post.reload
    assert_equal "Updated Post", post.title
    assert_equal({"tags" => %w[ruby rails], "priority" => "high"}, post.metadata)
    assert_instance_of Hash, post.metadata
  end

  test "handles invalid JSON gracefully in update" do
    post = posts(:one)
    invalid_json = '{"tags": ["ruby", "rails", "priority": "high"}' # Missing closing bracket

    put madmin_post_path(post), params: {
      post: {
        title: "Updated Post",
        metadata: invalid_json
      }
    }

    assert_response :redirect

    post.reload
    assert_equal "Updated Post", post.title
    # Should keep the invalid JSON as a string since parsing failed
    assert_equal invalid_json, post.metadata
  end

  test "does not affect non-JSON fields during update" do
    post = posts(:one)

    put madmin_post_path(post), params: {
      post: {
        title: "Simple Title",
        metadata: '{"test": true}'
      }
    }

    assert_response :redirect

    post.reload
    assert_equal "Simple Title", post.title
    assert_instance_of String, post.title
    assert_equal({"test" => true}, post.metadata)
    assert_instance_of Hash, post.metadata
  end
end
