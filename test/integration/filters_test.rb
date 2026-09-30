require "test_helper"

class FiltersTest < ActionDispatch::IntegrationTest
  setup do
    @chris = users(:one)
    @other = users(:two)
  end

  test "index shows the filters with a blank row and only filterable columns" do
    get madmin_users_path
    assert_response :success

    assert_select "button[popovertarget=filters]", text: "Filters"
    assert_select "#filters[popover] .filter-rows [data-filter-row]", count: 1
    assert_select "#filters select[name='filters[][column]'] option[value=first_name][data-filter-type=string]"
    assert_select "#filters select[name='filters[][column]'] option[value=ssn]", count: 0
    assert_select "#filters select[name='filters[][column]'] option[value=language]", count: 0
  end

  test "string filters" do
    assert_filtered [@chris], column: "first_name", operator: "contains", value: "hri"
    assert_filtered [@chris], column: "first_name", operator: "eq", value: "Chris"
    assert_filtered [@chris], column: "first_name", operator: "starts_with", value: "Ch"
    assert_filtered [], column: "first_name", operator: "contains", value: "%"

    @chris.update!(token: "abc123")
    @other.update!(token: "")
    assert_filtered [@other], column: "token", operator: "blank"
    assert_filtered [@chris], column: "token", operator: "present"
  end

  test "number filters" do
    assert_filtered [@chris], column: "balance", operator: "gt", value: "1000"
    assert_filtered [@chris], column: "balance", operator: "gte", value: "1234.5"
    assert_filtered [], column: "balance", operator: "lt", value: "1234.5"
    assert_filtered [@other], column: "balance", operator: "blank"
  end

  test "boolean filters" do
    assert_filtered [@chris], column: "admin", operator: "true"
    assert_filtered [@other], column: "admin", operator: "false"
  end

  test "date filters" do
    @other.update!(birthday: Date.new(1990, 1, 1))
    assert_filtered [@other], column: "birthday", operator: "eq", value: "1990-01-01"
    assert_filtered [@chris], column: "birthday", operator: "gte", value: "2000-01-01"
    assert_filtered [@other], column: "birthday", operator: "lte", value: "2000-01-01"
  end

  test "datetime filters use the time zone" do
    Time.use_zone("America/Chicago") do
      @chris.update!(created_at: Time.zone.parse("2026-08-15 09:30"))
      @other.update!(created_at: Time.zone.parse("2026-08-15 08:30"))

      assert_filtered [@chris], column: "created_at", operator: "gte", value: "2026-08-15T09:00"
      assert_filtered [@other], column: "created_at", operator: "lte", value: "2026-08-15T09:00"
    end
  end

  test "filters combine with AND, search and scopes" do
    assert_filtered [@chris], {column: "admin", operator: "true"}, {column: "last_name", operator: "eq", value: "Oliver"}
    assert_filtered [], {column: "admin", operator: "true"}, {column: "last_name", operator: "eq", value: "MyString"}

    get madmin_users_path(q: "MyString", filters: [{column: "admin", operator: "false", value: ""}])
    assert_equal [@other.id], listed_ids
  end

  test "ignores unknown columns, operators and blank values" do
    assert_filtered [@chris, @other], column: "ssn", operator: "eq", value: "123-45-6789"
    assert_filtered [@chris, @other], column: "password_digest", operator: "blank"
    assert_filtered [@chris, @other], column: "first_name", operator: "gt", value: "A"
    assert_filtered [@chris, @other], column: "first_name", operator: "contains", value: ""
    assert_filtered [@chris, @other], column: "birthday", operator: "eq", value: "not a date"

    get madmin_users_path(filters: "first_name")
    assert_response :success
  end

  test "active filters show as chips that remove themselves" do
    admin = {column: "admin", operator: "true", value: ""}
    name = {column: "first_name", operator: "contains", value: "Chr"}
    get madmin_users_path(q: "Oliver", filters: [admin, name])

    assert_select ".filters-count", text: "2"
    assert_select ".active-filters .filter-chip", count: 2
    assert_select ".filter-chip", text: /Admin\s+is true/
    assert_select ".filter-chip", text: /First name\s+contains\s+Chr/
    assert_select ".filter-chip a[href=?]", madmin_users_path(q: "Oliver", filters: [name])
    assert_select ".active-filters > a[href=?]", madmin_users_path(q: "Oliver"), text: "Clear filters"

    # The popover shows the active filters as rows
    assert_select "#filters .filter-rows [data-filter-row]", count: 2
    assert_select "#filters .filter-rows input[name='filters[][value]'][value=Chr]"
    assert_select "#filters .filter-rows input[name='filters[][value]'][hidden]", count: 1
  end

  test "sort, scope and search keep the filters" do
    filters = [{column: "admin", operator: "true", value: ""}]
    get madmin_users_path(filters: filters)

    assert_select "th a[href=?]", madmin_users_path(sort: "id", direction: "asc", filters: filters)
    assert_select "form.search input[type=hidden][name='filters[][column]'][value=admin]"
  end

  test "links keep the other params and go back to the first page" do
    filters = [{column: "admin", operator: "true", value: ""}]
    get madmin_posts_path(q: "My", scope: "recent", sort: "id", direction: "asc", page: 2, filters: filters)

    # Clearing the search keeps the scope, sort and filters
    assert_select ".header .actions a[href=?]", madmin_posts_path(scope: "recent", sort: "id", direction: "asc", filters: filters)
    assert_select "th a[href=?]", madmin_posts_path(q: "My", scope: "recent", sort: "id", direction: "desc", filters: filters)
  end

  test "filter: false hides a column" do
    UserResource.attributes[:token].field.options[:filter] = false
    get madmin_users_path
    assert_select "#filters select[name='filters[][column]'] option[value=token]", count: 0
  ensure
    UserResource.attributes[:token].field.options.delete(:filter)
  end

  private

  def assert_filtered(expected, *filters)
    filters = filters.map { |filter| {value: ""}.merge(filter) }
    get madmin_users_path(filters: filters)
    assert_response :success
    assert_equal expected.map(&:id).sort, listed_ids.sort, "filters: #{filters}"
  end

  def listed_ids
    css_select("tbody td.actions a:first-child").map { |link| link["href"][%r{/users/(\d+)\z}, 1].to_i }
  end
end
