# frozen_string_literal: true

require "test_helper"

class MenuTest < ActiveSupport::TestCase
  test "items added up front and from before_render render every time, before the resources" do
    menu = Madmin::Menu.new
    menu.add label: "Dashboard", url: "/madmin", position: 1
    menu.before_render { add label: "Reports", url: "/madmin/reports", position: 2 }

    2.times do
      labels = []
      menu.render { |item| labels << item.label }
      assert_equal %w[Dashboard Reports], labels.first(2)
      assert_includes labels, "Users"
    end
  end

  test "items nest under their parent" do
    menu = Madmin::Menu.new
    menu.add label: "Settings", position: 1
    menu.add label: "Keys", url: "/madmin/keys", parent: "Settings"

    settings = nil
    menu.render { |item| settings = item if item.label == "Settings" }
    assert_equal ["Keys"], settings.items.map(&:label)
  end

  test "rendering changes nothing, so a frozen menu renders" do
    menu = Madmin::Menu.new
    menu.add label: "Dashboard", url: "/madmin"
    Ractor.make_shareable(menu)

    labels = []
    menu.render { |item| labels << item.label }
    assert_includes labels, "Dashboard"
    assert_includes labels, "Users"
  end

  test "before_render blocks are shareable unless they capture something that isn't" do
    skip "Needs Ractor.shareable_proc" unless Ractor.respond_to?(:shareable_proc)
    menu = Madmin::Menu.new

    menu.before_render { add label: "Reports", url: "/madmin/reports" }
    assert Ractor.shareable?(menu.before_render)

    url = +"/madmin/reports" # a mutable String, which can't be shared
    menu.before_render { add label: "Reports", url: url }
    assert_not Ractor.shareable?(menu.before_render)
  end
end
