require "test_helper"

class PaginationTest < ActiveSupport::TestCase
  include Madmin::Pagination

  setup do
    @user = users(:one)
    Post.delete_all
    # Identical titles and timestamps so only the tiebreaker decides the order
    time = Time.current
    Post.insert_all!(7.times.map { {title: "Same", user_id: @user.id, created_at: time, updated_at: time} })
  end

  test "returns a page and a limited relation" do
    page, records = paginate(Post.all, page: 2, per_page: 3)

    assert_equal 7, page.count
    assert_equal 3, page.last
    assert_equal 3, records.to_a.size
  end

  test "pages never repeat or skip rows when sort values are tied" do
    ids = (1..3).flat_map { |number| paginate(Post.reorder(title: :desc), page: number, per_page: 3).last.map(&:id) }

    assert_equal Post.order(id: :desc).ids, ids
  end

  test "tiebreaker follows the direction of the ordering" do
    _, asc = paginate(Post.reorder(title: :asc), per_page: 3)
    _, desc = paginate(Post.reorder("title DESC"), per_page: 3)

    assert_equal Post.order(id: :asc).limit(3).ids, asc.map(&:id)
    assert_equal Post.order(id: :desc).limit(3).ids, desc.map(&:id)
  end

  test "does not add a tiebreaker when already ordered by primary key" do
    _, records = paginate(Post.reorder(id: :desc))

    assert_equal 1, records.order_values.size
  end

  test "pages past the end are empty" do
    page, records = paginate(Post.all, page: 50, per_page: 3)

    assert page.overflow?
    assert_empty records.to_a
  end

  test "counts relations with a custom select" do
    page, records = paginate(Post.select(:id, :title), per_page: 3)

    assert_equal 7, page.count
    assert_equal 3, records.to_a.size
  end

  test "counts grouped relations by number of groups" do
    page, records = paginate(Post.group(:user_id).select(:user_id), per_page: 3)

    assert_equal 1, page.count
    assert_equal 1, records.to_a.size
  end

  test "paginates distinct relations" do
    page, records = paginate(Post.select(:title).distinct, per_page: 3)

    assert_equal 1, page.count
    assert_equal ["Same"], records.map(&:title)
  end
end
