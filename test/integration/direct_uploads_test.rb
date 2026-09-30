require "test_helper"

class DirectUploadsTest < ActionDispatch::IntegrationTest
  test "file fields with direct_upload: true get the direct upload URL" do
    get edit_madmin_post_path(posts(:one))
    assert_select "input[type=file][name='post[image]'][data-direct-upload-url=?]", rails_direct_uploads_url
  end

  test "file fields without the option submit with the form" do
    get edit_madmin_post_path(posts(:one))
    assert_select "input[type=file][name='post[attachments][]']:not([data-direct-upload-url])"

    get edit_madmin_user_path(users(:one))
    assert_select "input[type=file][name='user[avatar]']:not([data-direct-upload-url])"
  end

  test "uploads through the form" do
    user = users(:one)
    put madmin_user_path(user), params: {user: {avatar: fixture_file_upload("avatar.txt", "text/plain")}}
    assert_response :redirect
    assert_equal "avatar.txt", user.reload.avatar.filename.to_s
  end

  test "saves a directly uploaded blob by its signed id" do
    post = posts(:one)
    blob = ActiveStorage::Blob.create_and_upload!(io: StringIO.new("image"), filename: "image.png", content_type: "image/png")

    put madmin_post_path(post), params: {post: {image: blob.signed_id}}
    assert_response :redirect
    assert_equal blob, post.reload.image.blob
  end
end
