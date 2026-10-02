require "test_helper"

class PageTest < ActiveSupport::TestCase
  test "invalid per_page params fall back to the default" do
    [nil, "", "abc", "0", "-5"].each do |param|
      assert_equal Madmin.per_page, Madmin::Page.new(count: 45, per_page: param).per_page
    end
  end

  test "per_page is capped at the largest option" do
    assert_equal 200, Madmin::Page.new(count: 45, per_page: 5_000_000).per_page
    assert_equal 200, Madmin::Page.new(count: 45, per_page: "99999999999999999999").per_page
  end

  test "per_page allows a configured default above the largest option" do
    original, Madmin.per_page = Madmin.per_page, 500
    assert_equal 500, Madmin::Page.new(count: 45).per_page
  ensure
    Madmin.per_page = original
  end

  test "per_page param follows the page param" do
    assert_equal "per_page", Madmin::Page.new(count: 1).per_page_param
    assert_equal "posts_per_page", Madmin::Page.new(count: 1, param: :posts_page).per_page_param
  end

  test "per_page options include the current size" do
    assert_equal [20, 50, 100, 200], Madmin::Page.new(count: 1, per_page: 20).per_page_options
    assert_equal [20, 25, 50, 100, 200], Madmin::Page.new(count: 1, per_page: 25).per_page_options
  end

  test "resizable when there are more records than the smallest size" do
    refute Madmin::Page.new(count: 20, per_page: 20).resizable?
    assert Madmin::Page.new(count: 21, per_page: 20).resizable?
    assert Madmin::Page.new(count: 15, per_page: 50).resizable? == false
    assert Madmin::Page.new(count: 15, per_page: 10).resizable?
  end

  test "first page" do
    page = Madmin::Page.new(count: 45, page: 1, per_page: 20)
    assert_equal 3, page.last
    assert_equal 0, page.offset
    assert_equal 1, page.from
    assert_equal 20, page.to
    assert_nil page.prev
    assert_equal 2, page.next
  end

  test "last page" do
    page = Madmin::Page.new(count: 45, page: 3, per_page: 20)
    assert_equal 40, page.offset
    assert_equal 41, page.from
    assert_equal 45, page.to
    assert_equal 2, page.prev
    assert_nil page.next
  end

  test "no records" do
    page = Madmin::Page.new(count: 0)
    assert_equal 1, page.last
    assert_equal 0, page.from
    assert_equal 0, page.to
    assert_nil page.prev
    assert_nil page.next
    assert_equal [1], page.series
  end

  test "invalid page params fall back to the first page" do
    [nil, "", "abc", "0", "-5"].each do |param|
      assert_equal 1, Madmin::Page.new(count: 45, page: param).page
    end
  end

  test "pages past the end are empty and link back into range" do
    page = Madmin::Page.new(count: 45, page: 10, per_page: 20)
    assert page.overflow?
    assert_equal 10, page.page
    assert_equal 0, page.from
    assert_equal 0, page.to
    assert_equal 3, page.prev
    assert_nil page.next
  end

  test "defaults to Madmin.per_page" do
    assert_equal Madmin.per_page, Madmin::Page.new(count: 1).per_page
  end

  test "series" do
    series = ->(page, count) { Madmin::Page.new(count: count, page: page, per_page: 1).series }

    assert_equal [1, 2, 3], series.call(1, 3)
    assert_equal [1, 2, 3, 4, 5, 6, 7], series.call(4, 7)
    assert_equal [1, 2, 3, 4, 5, :gap, 20], series.call(1, 20)
    assert_equal [1, :gap, 9, 10, 11, :gap, 20], series.call(10, 20)
    assert_equal [1, :gap, 16, 17, 18, 19, 20], series.call(20, 20)
    assert_equal [1, :gap, 16, 17, 18, 19, 20], series.call(99, 20)
  end
end
