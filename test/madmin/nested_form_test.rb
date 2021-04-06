require "test_helper"

class NestedHasManyTest < ActiveSupport::TestCase
  test "checks for the right field class" do
    field = UserResource.attributes.find { |i| i[:name] == :posts }[:field]
    field_comment = UserResource.attributes.find { |i| i[:name] == :comments }[:field]
    # Make sure :posts is a :nested_has_many type
    assert field.instance_of?(Madmin::Fields::NestedHasMany)
    refute field_comment.instance_of?(Madmin::Fields::NestedHasMany)
    assert_equal field.resource, PostResource
  end

  test "skips fields which is skipped in configuration" do
    field = UserResource.attributes.find { |i| i[:name] == :posts }[:field]

    # Make sure :enum is skipped in the UserResource
    refute field.to_param.values.flatten.include?(:enum)
    assert field.to_param.values.flatten.include?(:body)
  end

  test "whitelists unskipped and required params" do
    field = UserResource.attributes.find { |i| i[:name] == :posts }[:field]

    assert field.to_param == {posts_attributes: [:id, :title, :body, :image, {attachments: []}, "_destroy", "id"]}
  end
end
