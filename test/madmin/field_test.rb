require "test_helper"

class Madmin::FieldTest < ActiveSupport::TestCase
  test "required?" do
    attribute = PostResource.attributes.find { |a| a[:name] == :title }
    assert attribute[:field].required?

    attribute = PostResource.attributes.find { |a| a[:name] == :id }
    refute attribute[:field].required?
  end
end
