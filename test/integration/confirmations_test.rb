require "test_helper"

class ConfirmationsTest < ActionDispatch::IntegrationTest
  test "delete confirmation defaults to the generic message" do
    get madmin_user_path(users(:one))
    assert_response :success
    assert_select "form[action=?] [data-turbo-confirm=?]", madmin_user_path(users(:one)), "Are you sure?"
  end

  test "delete confirmation can include the resource and record name" do
    user = users(:one)

    with_translations(confirmations: {delete: "Delete the %{resource} %{name}?"}) do
      get madmin_user_path(user)
    end

    assert_select "form[action=?] [data-turbo-confirm=?]", madmin_user_path(user), "Delete the User #{UserResource.display_name(user)}?"
  end

  test "remove confirmation can include the attachment filename" do
    user = users(:one)
    user.avatar.attach(io: StringIO.new("avatar"), filename: "avatar.txt", content_type: "text/plain")

    with_translations(confirmations: {remove_with_changes: "Remove %{name}?"}) do
      get madmin_user_path(user)
    end

    assert_select "a[data-turbo-method=delete][data-turbo-confirm=?]", "Remove avatar.txt?"
  end

  private

  def with_translations(translations)
    # Load the locale files first so they don't overwrite these translations
    I18n.backend.eager_load!
    I18n.backend.store_translations(:en, madmin: translations)
    yield
  ensure
    I18n.reload!
  end
end
