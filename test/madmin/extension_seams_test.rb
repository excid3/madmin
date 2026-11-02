require "test_helper"

class ExtensionSeamsTest < ActiveSupport::TestCase
  test "model_column_names defaults to the model's column names" do
    assert_equal Post.column_names, PostResource.model_column_names
  end

  test "sortable_columns delegates to model_column_names" do
    resource = Class.new(PostResource) do
      def self.model_column_names
        ["id", "title"]
      end
    end

    assert_equal ["id", "title"], resource.sortable_columns
  end
end

class NonActiveRecordModelTest < ActiveSupport::TestCase
  class ApiRecord
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :id, :integer
    attribute :name, :string
    attribute :published, :boolean
  end

  class PlainRecord
    include ActiveModel::Model

    attr_accessor :name
  end

  class ApiRecordResource < Madmin::Resource
    model ApiRecord

    attribute :id
    attribute :name
    attribute :published
    attribute :author
  end

  test "infers types from ActiveModel attributes" do
    assert_equal :integer, ApiRecordResource.get_attribute(:id).type
    assert_equal :string, ApiRecordResource.get_attribute(:name).type
    assert_equal :boolean, ApiRecordResource.get_attribute(:published).type
    assert_instance_of Madmin::Fields::Boolean, ApiRecordResource.get_attribute(:published).field
  end

  test "defaults to a String field for attributes the model doesn't declare" do
    assert_nil ApiRecordResource.get_attribute(:author).type
    assert_instance_of Madmin::Fields::String, ApiRecordResource.get_attribute(:author).field
  end

  test "models without attribute types get String fields" do
    resource = Class.new(Madmin::Resource) do
      model PlainRecord
      attribute :name
    end

    assert_instance_of Madmin::Fields::String, resource.get_attribute(:name).field
  end

  test "search passes through collections without a table" do
    records = [ApiRecord.new(id: 1, name: "one"), ApiRecord.new(id: 2, name: "two")]

    assert_same records, Madmin::Search.new(records, ApiRecordResource, "one").run
    assert_same records, Madmin::Search.new(records, ApiRecordResource, "").run
  end
end
