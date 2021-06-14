require "test_helper"

class Madmin::FieldTest < ActiveSupport::TestCase
  test "required?" do
    attribute = PostResource.attributes.find { |a| a[:name] == :title }
    assert attribute[:field].required?

    attribute = PostResource.attributes.find { |a| a[:name] == :id }
    refute attribute[:field].required?
  end

  test "searchable?" do
    attribute = PostResource.attributes.find { |a| a[:name] == :title }
    assert attribute[:field].searchable?

    attribute = PostResource.attributes.find { |a| a[:name] == :created_at }
    refute attribute[:field].searchable?
  end
end
