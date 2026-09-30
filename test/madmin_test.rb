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

  test "has many and nested has many are set to paginateable, others are not" do
    assert UserResource.get_attribute(:posts).field.paginateable?
    assert UserResource.get_attribute(:comments).field.paginateable?
    refute UserResource.get_attribute(:id).field.paginateable?
  end

  test "resource_for with STI fallback" do
    assert_equal EventResource, Madmin.resource_for(CommentEvent.new)
  end

  # A model whose class name matches no resource, and which no resource declares.
  class Nobody < ApplicationRecord
    self.table_name = "posts"
  end

  test "resource_for falls back to the resource that declares the model" do
    # BlogArticleResource is named for the operator, not the model; it says
    # `model Article`, and there is no ArticleResource.
    assert_equal BlogArticleResource, Madmin.resource_for(Article.new)
  end

  test "resource_for prefers the name-derived resource over another that merely declares the model" do
    other = Class.new(Madmin::Resource) { model User }

    with_extra_resources(other) do
      assert_equal UserResource, Madmin.resource_for(User.new)
    end
  end

  test "resource_for still raises when no resource matches by name or by declaration" do
    assert_raises(Madmin::MissingResource) { Madmin.resource_for(Nobody.new) }
  end

  test "resource_for raises rather than guess when two differently-named resources declare the same model" do
    first = Class.new(Madmin::Resource) { model Nobody }
    second = Class.new(Madmin::Resource) { model Nobody }

    with_extra_resources(first, second) do
      error = assert_raises(Madmin::MissingResource) { Madmin.resource_for(Nobody.new) }
      assert_match(/all declare `model Madmin::Test::Nobody`/, error.message)
    end
  end

  test "reset_resources! forgets the declared-model index" do
    resource = Class.new(Madmin::Resource) { model Nobody }

    with_extra_resources(resource) do
      assert_equal resource, Madmin.resource_for(Nobody.new)
    end

    assert_raises(Madmin::MissingResource) { Madmin.resource_for(Nobody.new) }
  end

  test "resource_for falls back to the resource declaring a superclass of the model" do
    subclass = Class.new(Article)

    assert_equal BlogArticleResource, Madmin.resource_for(subclass.new)
  end

  test "resource_by_name falls back to the resource that declares the model" do
    assert_equal BlogArticleResource, Madmin.resource_by_name(Article)
    assert_equal BlogArticleResource, Madmin.resource_by_name("Article")
    assert_equal PostResource, Madmin.resource_by_name(Post)
    assert_raises(Madmin::MissingResource) { Madmin.resource_by_name(Nobody) }
  end

  # A model associated with Article, whose resource is BlogArticleResource.
  class Note < ApplicationRecord
    self.table_name = "comments"
    belongs_to :article, foreign_key: :commentable_id
    has_many :articles, foreign_key: :user_id
  end

  test "association fields find a resource named differently from its model" do
    [Madmin::Fields::BelongsTo.new(attribute_name: :article, model: Note, resource: CommentResource, options: {}),
      Madmin::Fields::HasMany.new(attribute_name: :articles, model: Note, resource: CommentResource, options: {})].each do |field|
      assert_equal BlogArticleResource, field.associated_resource
      assert_equal BlogArticleResource, field.associated_resource_for(Article.new)
    end
  end

  private

  # Madmin.resources is built from files on disk, so a resource defined inside
  # a test is invisible to it. Splice extras into the memo for the block, then
  # reset so neither the list nor the declared-model index leaks.
  def with_extra_resources(*extras)
    Madmin.reset_resources!
    Madmin.instance_variable_set(:@resources, Madmin.resources + extras)
    yield
  ensure
    Madmin.reset_resources!
  end
end
