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
  end

  test "can update user" do
    user = users(:one)
    put madmin_user_path(user), params: {user: {first_name: "Updated"}}
    assert_response :redirect
    assert_equal "Updated", user.reload.first_name
  end

  test "can delete user" do
    assert_difference "User.count", -1 do
      delete madmin_user_path(users(:one))
      assert_response :redirect
    end
  end
end
