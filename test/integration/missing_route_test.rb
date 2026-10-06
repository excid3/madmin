require "test_helper"

# A model with a resource but no routes drawn for it. Both are defined here so
# the dummy app's routes and menu stay untouched.
module Unrouted
  class Thing < ApplicationRecord
    self.table_name = "posts"
    has_many :comments, as: :commentable
  end

  # No resource at all
  class Stray < ApplicationRecord
    self.table_name = "posts"
  end

  class Note < ApplicationRecord
    self.table_name = "comments"
    belongs_to :thing, foreign_key: :commentable_id
    belongs_to :stray, foreign_key: :commentable_id
  end

  class ThingResource < Madmin::Resource
    attribute :id, form: false
    attribute :title

    def self.display_name(record)
      "Thing: #{record.title}"
    end
  end
end

class MissingRouteTest < ActionDispatch::IntegrationTest
  setup do
    @thing = Unrouted::Thing.find(posts(:one).id)
  end

  test "path helpers raise MissingRoute with the route to add" do
    error = assert_raises(Madmin::MissingRoute) { Unrouted::ThingResource.index_path }

    assert_match "`madmin_unrouted_things_path` is not defined, so Unrouted::ThingResource has no route", error.message
    assert_match "    namespace :unrouted do\n      resources :things do\n        collection { delete :bulk_destroy }\n      end\n    end", error.message
    assert_match "menu false", error.message
    assert_kind_of NoMethodError, error.cause

    assert_raises(Madmin::MissingRoute) { Unrouted::ThingResource.new_path }
    assert_raises(Madmin::MissingRoute) { Unrouted::ThingResource.show_path(@thing) }
    assert_raises(Madmin::MissingRoute) { Unrouted::ThingResource.edit_path(@thing) }
  end

  test "path helpers still work for routed resources" do
    assert_equal madmin_posts_path, PostResource.index_path
    assert_equal madmin_post_path(posts(:one)), PostResource.show_path(posts(:one))
  end

  test "index renders an association to an unrouted resource as text" do
    Comment.create!(user: users(:one), commentable: @thing, body: "on a thing")

    get madmin_comments_path

    assert_response :success
    assert_select "td", text: "Thing: #{@thing.title}"
    assert_select "td a", text: "Thing: #{@thing.title}", count: 0
  end

  test "show renders an association to an unrouted resource as text" do
    comment = Comment.create!(user: users(:one), commentable: @thing, body: "on a thing")

    get madmin_comment_path(comment)

    assert_response :success
    assert_match "Thing: #{@thing.title}", response.body
    assert_select "a", text: "Thing: #{@thing.title}", count: 0
  end

  test "association select has no remote url when the associated resource has no index route" do
    %w[BelongsTo HasMany].each do |type|
      field = Madmin::Fields.const_get(type).new(attribute_name: :thing, model: Unrouted::Note, resource: CommentResource, options: {})
      assert_equal Unrouted::ThingResource, field.associated_resource
      assert_nil field.index_path
    end
  end

  test "resource_by_name raises MissingResource with the generator command" do
    error = assert_raises(Madmin::MissingResource) { Madmin.resource_by_name("Nope") }
    assert_match "bin/rails generate madmin:resource Nope", error.message
  end

  test "association select has no remote url when the associated resource is missing" do
    field = Madmin::Fields::BelongsTo.new(attribute_name: :stray, model: Unrouted::Note, resource: CommentResource, options: {})
    assert_nil field.associated_resource
    assert_nil field.index_path
  end
end
