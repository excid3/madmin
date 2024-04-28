require "test_helper"

class Madmin::Test < ActiveSupport::TestCase
  test "can find model" do
    assert_equal UserResource.model, User
  end

  test "can find nested model" do
    assert_equal ActionText::RichTextResource.model, ActionText::RichText
    assert_equal User::ConnectedAccountResource.model, User::ConnectedAccount
  end

  test "stores scopes" do
    assert_equal UserResource.scopes, []
  end

  test "stores attributes" do
    assert_instance_of ActiveSupport::OrderedHash, UserResource.attributes
    assert_equal :id, UserResource.attributes.keys.first
  end

  test "can infer attribute type" do
    assert_equal UserResource.send(:infer_type, :id), :integer
    assert_equal UserResource.send(:infer_type, :first_name), :string
    assert_equal UserResource.send(:infer_type, :created_at), :datetime
    assert_equal UserResource.send(:infer_type, :posts), :has_many

    assert_equal UserResource.send(:infer_type, :virtual_attribute), :string

    assert_equal PostResource.send(:infer_type, :body), :rich_text
    assert_equal PostResource.send(:infer_type, :user), :belongs_to
    assert_equal PostResource.send(:infer_type, :image), :attachment
    assert_equal PostResource.send(:infer_type, :attachments), :attachments
    assert_equal PostResource.send(:infer_type, :state), :enum

    assert_equal CommentResource.send(:infer_type, :commentable), :polymorphic
  end

  test "can set custom field for attribute" do
    assert_equal CustomField, PostResource.get_attribute(:title).field.class
  end
end
