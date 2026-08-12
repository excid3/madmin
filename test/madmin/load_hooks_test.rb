require "test_helper"

module LoadHookProbe
  def load_hook_probe
    "probed"
  end
end

class LoadHooksTest < ActiveSupport::TestCase
  # Hooks registered after the base has already loaded run immediately, so each
  # test references the constant first to make sure it has been loaded.
  def assert_load_hook(name, expected)
    expected.name # force autoload
    base = nil
    ActiveSupport.on_load(name) { base = self }
    assert_equal expected, base, "Expected #{name} load hook to run with #{expected}"
  end

  test "madmin_resource load hook" do
    assert_load_hook :madmin_resource, Madmin::Resource
  end

  test "madmin_field load hook" do
    assert_load_hook :madmin_field, Madmin::Field
  end

  test "madmin_search load hook" do
    assert_load_hook :madmin_search, Madmin::Search
  end

  test "madmin_base_controller load hook" do
    assert_load_hook :madmin_base_controller, Madmin::BaseController
  end

  test "madmin_resource_controller load hook" do
    assert_load_hook :madmin_resource_controller, Madmin::ResourceController
  end

  test "load hooks can extend the resource DSL" do
    refute_respond_to Madmin::Resource, :load_hook_probe

    ActiveSupport.on_load(:madmin_resource) { extend LoadHookProbe }

    assert_equal "probed", Madmin::Resource.load_hook_probe
    assert_equal "probed", PostResource.load_hook_probe
  ensure
    # The hook stays registered, but nothing re-runs :madmin_resource in the
    # test process, so undefining the method is enough to clean up.
    Madmin::Resource.singleton_class.undef_method(:load_hook_probe)
  end
end
