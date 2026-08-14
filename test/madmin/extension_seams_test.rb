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
