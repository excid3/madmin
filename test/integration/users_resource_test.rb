require "test_helper"

class UsersResourceTest < ActionDispatch::IntegrationTest
  test "can see the users index" do
    get madmin_users_path
    assert_response :success
  end

  test "can see the users new" do
    get new_madmin_user_path
    assert_response :success
  end

  test "can visit new with query params to prefill values" do
    get new_madmin_user_path(user: {first_name: "Chris"})
    assert_select "input[name='user[first_name]'][value=?]", "Chris"
  end

  test "can create user" do
    assert_difference "User.count" do
      post madmin_users_path, params: {user: {first_name: "Updated", password: "password", password_confirmation: "password"}}
      assert_response :redirect
    end
  end

  test "can see the users show" do
    get madmin_user_path(users(:one))
    assert_response :success
  end

  test "can see the users edit" do
    get edit_madmin_user_path(users(:one))
    assert_response :success
    assert_select "input[type=checkbox][name='user[admin]'][checked]"
    assert_select "input[type=number][name='user[balance]'][value='1234.5']"
    assert_select "select[name='user[digest_time(4i)]'] option[selected][value='08']"
  end

  test "can update user" do
    user = users(:one)
    put madmin_user_path(user), params: {user: {first_name: "Updated"}}
    assert_response :redirect
    assert_equal "Updated", user.reload.first_name
  end

  test "shows boolean, currency, time and has_one fields" do
    user = users(:one)
    post = user.posts.create!(title: "Latest")

    get madmin_users_path
    assert_select "td", text: "$1,234.50"

    get madmin_user_path(user)
    assert_select "td", text: "true"
    assert_select "td", text: "$1,234.50"
    assert_select "td", text: /08:30/
    assert_select "a[href=?]", madmin_post_path(post)
  end

  test "can update boolean, currency and time fields" do
    user = users(:two)
    put madmin_user_path(user), params: {user: {admin: "1", balance: "99.95", "digest_time(4i)": "18", "digest_time(5i)": "15"}}
    assert_response :redirect

    user.reload
    assert user.admin?
    assert_equal BigDecimal("99.95"), user.balance
    assert_equal "18:15", user.digest_time.strftime("%H:%M")
  end

  test "can delete user" do
    assert_difference "User.count", -1 do
      delete madmin_user_path(users(:two))
      assert_response :redirect
    end
  end
end
