require "test_helper"

class PaginationIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    time = Time.current
    Post.delete_all
    Post.insert_all!(45.times.map { |i| {title: "Paginated #{i}", user_id: @user.id, created_at: time, updated_at: time} })
  end

  test "index paginates and preserves query params" do
    get madmin_posts_path(q: "Paginated", sort: "title", direction: "asc")
    assert_response :success
    assert_select ".pagination .pages a[aria-current=page]", text: "1"
    assert_select ".pagination .pages a[href*='page=2'][href*='q=Paginated'][href*='sort=title'][href*='direction=asc']"
    assert_select ".pagination-info", text: /1-20 of 45/

    get madmin_posts_path(q: "Paginated", page: 3)
    assert_select ".pagination .pages a[aria-current=page]", text: "3"
    assert_select ".pagination-info", text: /41-45 of 45/
    assert_select "tbody tr", 5
  end

  test "index honors per_page" do
    get madmin_posts_path(per_page: 25)
    assert_select "tbody tr", 25
    assert_select ".per-page a[aria-current]", text: "25"
    assert_select ".per-page a[href*='per_page=20']"
  end

  test "page size links keep the query params and go back to the first page" do
    get madmin_posts_path(q: "Paginated", page: 2)
    assert_select ".per-page a[href*='per_page=50'][href*='q=Paginated']"
    assert_empty css_select(".per-page a[href]").select { |link| link["href"].match?(/[?&]page=/) }
  end

  test "index serves an empty page past the end" do
    get madmin_posts_path(q: "Paginated", page: 99)
    assert_response :success
    assert_select "tbody tr", 0
    assert_select ".pagination .pages a[href*='page=3']"
  end

  test "index ignores invalid page params" do
    get madmin_posts_path(page: "abc")
    assert_response :success
    assert_select ".pagination .pages a[aria-current=page]", text: "1"
  end

  test "index hides page links when there is a single page" do
    get madmin_users_path
    assert_response :success
    assert_select ".pagination .pages", 0
    assert_select ".per-page", 0
  end

  test "countless resources page with previous and next links only" do
    Event.insert_all!(45.times.map { {type: "CommentEvent", created_at: Time.current, updated_at: Time.current} })

    get madmin_events_path
    assert_response :success
    assert_select "tbody tr", 20
    assert_select ".pagination .pages a[href*='page=2']"
    assert_select ".pagination .pages a[aria-current=page]", 0
    assert_select ".pagination-info", text: /\A\s*Displaying 1-20\s*\z/
    assert_select ".per-page a[href*='per_page=50']"

    get madmin_events_path(page: 3)
    assert_select "tbody tr", 5
    assert_select ".pagination .pages a[href*='page=2']"
    assert_select ".pagination .pages a[href*='page=4']", 0
    assert_select ".pagination-info", text: /41-45/
  end

  test "countless resources hide page links when everything fits on one page" do
    Event.insert_all!(3.times.map { {type: "CommentEvent", created_at: Time.current, updated_at: Time.current} })

    get madmin_events_path
    assert_select ".pagination .pages", 0
    assert_select ".per-page", 0
    assert_select ".pagination-info", text: /Displaying 1-3/
  end

  test "json index is paginated" do
    get madmin_posts_path(format: :json)
    assert_equal Madmin.per_page, response.parsed_body.size
  end

  test "has many fields paginate with their own param" do
    get madmin_user_path(@user, posts_page: 2)
    assert_response :success
    assert_select ".pagination .pages a[aria-current=page]", text: "2"
    assert_select ".pagination .pages a[href*='posts_page=3']"
  end

  test "has many fields change page size with their own param" do
    get madmin_user_path(@user, posts_per_page: 50, posts_page: 1)
    assert_select ".pagination-info", text: /1-45 of 45/
    assert_select ".per-page a[aria-current]", text: "50"
    assert_select ".per-page a[href*='posts_per_page=100']"
    assert_select ".per-page a[href*='posts_page=']", 0
  end
end
