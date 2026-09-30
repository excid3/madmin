require "test_helper"

class NestedHasOneTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "edit form without a record only has the fields in the template" do
    get edit_madmin_user_path(@user)
    assert_response :success

    template = response.body[%r{<template data-nested-form-target="template">.*?</template>}m]
    assert_includes template, "user[profile_attributes][bio]"
    assert_not_includes response.body.sub(template, ""), "user[profile_attributes][bio]"
    assert_select "[data-nested-form-target=links]:not([hidden]) a", text: "+ Add new"
  end

  test "saving without adding a record doesn't create one" do
    assert_no_difference "User::Profile.count" do
      put madmin_user_path(@user), params: {user: {first_name: "Updated"}}
    end
    assert_nil @user.reload.profile
  end

  test "creates the record" do
    assert_difference "User::Profile.count" do
      put madmin_user_path(@user), params: {user: {profile_attributes: {bio: "Hello", website: "https://example.com", _destroy: "false"}}}
      assert_response :redirect
    end
    assert_equal "Hello", @user.reload.profile.bio
  end

  test "edit form shows the existing record and hides the add link" do
    profile = @user.create_profile!(bio: "Hello")

    get edit_madmin_user_path(@user)
    assert_select "textarea[name='user[profile_attributes][bio]']", text: "Hello"
    assert_select "input[type=hidden][name='user[profile_attributes][id]'][value=?]", profile.id.to_s
    assert_select "[data-nested-form-target=links][hidden]"
  end

  test "updates the record" do
    profile = @user.create_profile!(bio: "Hello")

    assert_no_difference "User::Profile.count" do
      put madmin_user_path(@user), params: {user: {profile_attributes: {id: profile.id, bio: "Updated"}}}
    end
    assert_equal "Updated", profile.reload.bio
  end

  test "removes the record" do
    profile = @user.create_profile!(bio: "Hello")

    assert_difference "User::Profile.count", -1 do
      put madmin_user_path(@user), params: {user: {profile_attributes: {id: profile.id, _destroy: "1"}}}
    end
  end

  test "show and index link to the record" do
    profile = @user.create_profile!(bio: "Hello")

    get madmin_user_path(@user)
    assert_select "a[href=?]", madmin_user_profile_path(profile), text: "Profile ##{profile.id}"
  end

  test "looks up the associated class through the association" do
    field = UserResource.attributes[:profile].field
    assert_equal User::Profile, field.to_model
    assert_equal User::ProfileResource, field.resource
  end
end
