100.times do
  user = User.create!(
    first_name: FFaker::Name.first_name,
    last_name: FFaker::Name.last_name,
    birthday: Date.today,
    password: "password",
    admin: rand < 0.1,
    balance: rand(0.0..1000.0).round(2),
    digest_time: format("%02d:00", rand(6..20))
  )

  # For pagination testing
  100.times do
    Post.create!(
      title: FFaker::Lorem.sentence,
      user:,
    )
  end
end