# frozen_string_literal: true

require "test_helper"

# Madmin.ractorize! freezes the settings and resources for good, so each of
# these tests runs in a process of its own
class RactorTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::Isolation

  # Nothing here needs records. Loading the fixtures in the forked process
  # trips PostgreSQL's foreign keys when this class happens to run first
  self.fixture_table_names = []
  self.use_transactional_tests = false

  setup do
    Madmin.menu.add label: "Dashboard", url: "/madmin"
  end

  test "ractorize! makes the settings, menu and resources shareable" do
    Madmin.ractorize!

    assert_shareable Madmin.site_name, Madmin.stylesheets, Madmin.resource_locations, Madmin.menu
    assert_shareable Madmin.resources, Madmin.resources_by_model
    assert_shareable Madmin::Filter::OPERATORS, Madmin::Filter::WITHOUT_VALUE, Madmin::Filter::MATCHING_OPERATORS,
      Madmin::Page::PER_PAGE_OPTIONS, Madmin::FiltersHelper::FILTER_INPUT_TYPES
    Madmin.resources.each do |resource|
      assert_shareable resource.attributes, resource.scopes, resource.member_actions, resource.collection_actions
    end
  end

  test "the menu renders once shared" do
    Madmin.ractorize!

    labels = []
    Madmin.menu.render { |item| labels << item.label }
    assert_includes labels, "Dashboard"
    assert_includes labels, "Users"
  end

  test "before_render blocks are shared too" do
    skip "Needs Ractor.shareable_proc" unless Ractor.respond_to?(:shareable_proc)
    Madmin.menu.before_render { add label: "Reports", url: "/madmin/reports", position: 1 }
    Madmin.ractorize!

    labels = []
    Madmin.menu.render { |item| labels << item.label }
    assert_equal "Reports", labels.first
  end

  # Before Ruby 4.0 no block written outside a class body can be shared, since
  # its self can't be. From 4.0 the catch is capturing something unshareable
  test "ractorize! reports a before_render block that can't be shared" do
    url = +"/madmin/reports" # a mutable String, which can't be shared
    Madmin.menu.before_render { add label: "Reports", url: url }

    assert_raises(Ractor::IsolationError) { Madmin.ractorize! }
  end

  test "Madmin can be used from another Ractor" do
    skip "Needs Ruby 4.0 and Rails' Ractor support" unless RUBY_VERSION >= "4.0" && defined?(ActiveSupport::Ractors)
    Madmin.ractorize!

    result = on_ractor do
      {
        per_page: Madmin.per_page,
        site_name: Madmin.site_name,
        stylesheets: Madmin.stylesheets,
        resources: Madmin.resources.map(&:name),
        resource: Madmin.resource_by_name("User").name,
        attributes: UserResource.attributes.keys,
        field: UserResource.get_attribute(:id).field.class.name,
        operators: Madmin::Filter::OPERATORS[:string],
        series: Madmin::Page.new(count: 100).series
      }
    end

    assert_equal 20, result[:per_page]
    assert_equal "Dummy", result[:site_name]
    assert_includes result[:stylesheets], "dummy"
    assert_includes result[:resources], "UserResource"
    assert_equal "UserResource", result[:resource]
    assert_equal :id, result[:attributes].first
    assert_equal "Madmin::Fields::Integer", result[:field]
    assert_equal %w[contains eq starts_with blank present], result[:operators]
    assert_equal [1, 2, 3, 4, 5], result[:series]
  end

  private

  def assert_shareable(*objects)
    objects.each do |object|
      assert Ractor.shareable?(object), "Expected #{object.inspect[0, 200]} to be Ractor-shareable"
    end
  end

  # Runs the block on a new Ractor and returns what it returns
  def on_ractor(&block)
    experimental, Warning[:experimental] = Warning[:experimental], false
    Ractor.new(Ractor.shareable_proc(self: nil, &block)) { |b| b.call }.value
  rescue Ractor::RemoteError => error
    raise error.cause, cause: nil
  ensure
    Warning[:experimental] = experimental
  end
end
