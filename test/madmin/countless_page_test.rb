require "test_helper"

class CountlessPageTest < ActiveSupport::TestCase
  test "has no total or page numbers" do
    page = Madmin::CountlessPage.new(page: 2, per_page: 20, fetched: 21)
    assert_nil page.count
    assert_equal [], page.series
  end

  test "a full fetch means there is a next page" do
    page = Madmin::CountlessPage.new(page: 2, per_page: 20, fetched: 21)
    assert page.more?
    assert_equal 20, page.size
    assert_equal 21, page.from
    assert_equal 40, page.to
    assert_equal 1, page.prev
    assert_equal 3, page.next
    assert_equal 3, page.last
    refute page.overflow?
  end

  test "a short fetch is the last page" do
    page = Madmin::CountlessPage.new(page: 3, per_page: 20, fetched: 5)
    refute page.more?
    assert_equal 41, page.from
    assert_equal 45, page.to
    assert_equal 2, page.prev
    assert_nil page.next
    assert_equal 3, page.last
  end

  test "first and only page" do
    page = Madmin::CountlessPage.new(per_page: 20, fetched: 5)
    assert_equal 1, page.from
    assert_equal 5, page.to
    assert_nil page.prev
    assert_nil page.next
    assert_equal 1, page.last
    refute page.resizable?
  end

  test "no records" do
    page = Madmin::CountlessPage.new
    assert_equal 0, page.from
    assert_equal 0, page.to
    refute page.overflow?
  end

  test "pages past the end are empty and link back" do
    page = Madmin::CountlessPage.new(page: 10, per_page: 20, fetched: 0)
    assert page.overflow?
    assert_equal 0, page.to
    assert_equal 9, page.prev
    assert_nil page.next
  end

  test "resizable when another page size would change what is shown" do
    assert Madmin::CountlessPage.new(per_page: 20, fetched: 21).resizable?
    assert Madmin::CountlessPage.new(page: 2, per_page: 20, fetched: 3).resizable?
    refute Madmin::CountlessPage.new(per_page: 20, fetched: 20).resizable?
  end
end
