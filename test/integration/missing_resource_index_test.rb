require "test_helper"

# A record whose class has no matching Madmin resource. `Madmin.resource_for`
# asks the class for `inheritance_column` and `column_names` before giving up,
# so this has to be a real ActiveRecord model; `posts` has no `type` column, so
# the STI branch declines too and we reach the MissingResource the field classes
# rescue. Defined here, not in the dummy app, so nothing else can grow a
# resource for it by accident.
class Orphan < ApplicationRecord
  self.table_name = "posts"
  has_many :comments, as: :commentable
end

class MissingResourceIndexTest < ActionDispatch::IntegrationTest
  setup do
    @orphan = Orphan.find(posts(:one).id)
    @comment = Comment.create!(user: users(:one), commentable: @orphan, body: "on an orphan")
  end

  test "index renders a polymorphic target with no resource as a missing-resource notice instead of raising" do
    get madmin_comments_path

    assert_response :success
    assert_select "tbody tr", minimum: 1
    assert_match "OrphanResource is missing", response.body
  end

  test "index still links a polymorphic target whose resource exists" do
    get madmin_comments_path

    assert_response :success
    assert_select "a[href=?]", madmin_post_path(posts(:one))
  end

  test "belongs_to and has_one index cells degrade the same way as polymorphic" do
    %w[belongs_to has_one].each do |field_type|
      field = "Madmin::Fields::#{field_type.camelize}".constantize.new(
        attribute_name: :thing, model: Comment, resource: CommentResource, options: {}
      )

      assert_nil field.associated_resource_for(@orphan), "#{field_type}: the guarded accessor rescues the miss"

      html = Madmin::ApplicationController.render(
        partial: "madmin/fields/#{field_type}/index",
        locals: {field: field, record: Struct.new(:thing).new(@orphan), resource: CommentResource}
      )

      assert_match "OrphanResource is missing", html, "#{field_type}/_index should degrade like #{field_type}/_show"
    end
  end
end
