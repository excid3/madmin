require "test_helper"

class AttachmentRemoveLinkTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user.avatar.attach(io: StringIO.new("avatar"), filename: "avatar.txt", content_type: "text/plain")
    @remove_path = madmin_active_storage_attachment_path(@user.avatar.attachment)
  end

  test "show and edit link to remove the attachment" do
    get madmin_user_path(@user)
    assert_response :success
    assert_select "a[href=?][data-turbo-method=delete]", @remove_path, count: 1

    get edit_madmin_user_path(@user)
    assert_response :success
    assert_select "a[href=?][data-turbo-method=delete]", @remove_path, count: 1
  end

  test "show and edit omit the remove link and menu item when the attachment routes are not drawn" do
    without_attachment_routes do
      get madmin_user_path(@user)
      assert_response :success
      assert_select "a[data-turbo-method=delete]", count: 0
      assert_select "a[href=?]", madmin_active_storage_blobs_path

      get edit_madmin_user_path(@user)
      assert_response :success
      assert_select "a[data-turbo-method=delete]", count: 0
    end
  end

  test "show omits the remove link when the attachment resource is missing" do
    without_attachment_resource do
      get madmin_user_path(@user)
      assert_response :success
      assert_select "a[data-turbo-method=delete]", count: 0
    end
  end

  test "menu links to the attachments index" do
    get madmin_user_path(@user)
    assert_select "a[href=?]", madmin_active_storage_attachments_path
  end

  test "menu keeps a resource without an index route when it has a custom url" do
    without_attachment_routes do
      ActiveStorage::AttachmentResource.menu url: "/custom-attachments"
      get madmin_user_path(@user)
      assert_select "a[href=?]", "/custom-attachments"
    ensure
      ActiveStorage::AttachmentResource.menu({})
    end
  end

  test "route? is true for drawn actions only" do
    assert PostResource.route?(:destroy)
    assert PostResource.route?(:publish)
    assert_not PostResource.route?(:missing)
    assert ActiveStorage::AttachmentResource.route?(:destroy)

    without_attachment_routes do
      assert_not ActiveStorage::AttachmentResource.route?(:destroy)
      assert ActiveStorage::BlobResource.route?(:destroy)
    end
  end

  private

  # Redraws the dummy app's routes without the Madmin attachment routes, as an
  # app removing them would. Active Storage's own routes are kept since the
  # views link to the files.
  def without_attachment_routes
    routes = Rails.root.join("config/routes/madmin.rb").read.sub(/^  namespace :active_storage do\n    resources :attachments\n  end\n/, "")
    app_routes = Rails.application.routes
    app_routes.disable_clear_and_finalize = true
    app_routes.clear!
    load ActiveStorage::Engine.root.join("config/routes.rb")
    app_routes.draw do
      root to: "home#index"
      instance_eval(routes)
    end
    app_routes.finalize!
    Madmin.reset_resources!
    yield
  ensure
    Rails.application.routes.disable_clear_and_finalize = false
    Rails.application.reload_routes!
    Madmin.reset_resources!
  end

  def without_attachment_resource
    original = Madmin.method(:resource_for)
    Madmin.define_singleton_method(:resource_for) do |object|
      raise Madmin::MissingResource if object.is_a?(ActiveStorage::Attached)
      original.call(object)
    end
    yield
  ensure
    Madmin.define_singleton_method(:resource_for, original)
  end
end
