100.times do
  user = User.create!(
    first_name: FFaker::Name.first_name,
    last_name: FFaker::Name.last_name,
    birthday: Date.today,
    password: "password"
  )

  # For pagination testing
  100.times do
    Post.create!(
      title: FFaker::Lorem.sentence,
      user:,
    )
  end
end