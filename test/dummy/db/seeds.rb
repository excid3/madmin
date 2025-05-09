require 'action_mailbox/test_helper'
include ActionMailbox::TestHelper

10.times do
  Numerical.create!(
    decimal: rand(1..100).to_f,
    float: rand(1..100).to_f
  )
end

100.times do
  user = User.create!(
    first_name: FFaker::Name.first_name,
    last_name: FFaker::Name.last_name,
    birthday: FFaker::Time.between(80.years.ago, 18.years.ago).to_date,
    password: "password",
    ssn: FFaker::SSN.ssn,
    preferences: { language: ['en', 'es', 'fr'].sample, notifications: [true, false].sample },
    settings: { weekly_email: [true, false].sample, monthly_newsletter: [true, false].sample },
    numerical: Numerical.all.sample,
    active: [true, false].sample,
    balance: rand(1..100).to_f,
    last_login_time: FFaker::Time.between(1.year.ago, Time.now)
  )
end

sample_image_blob = ActiveStorage::Blob.create_and_upload!(
  io: File.open(Rails.root.join('app', 'assets', 'images', 'sample.jpg')),
  filename: 'sample.jpg',
  content_type: 'image/jpeg'
)

sample_avatar_blob = ActiveStorage::Blob.create_and_upload!(
  io: File.open(Rails.root.join('app', 'assets', 'images', 'avatar.jpg')),
  filename: 'avatar.png',
  content_type: 'image/png'
)

User.all.last(20).each do |user|

  user.connected_accounts.create!(
    service: ['facebook', 'google', 'twitter'].sample
  )

  3.times do
    post = user.posts.create!(
      title: FFaker::Music.song,
      state: Post.states.keys.sample,
      created_at: Time.now - rand(1..3).weeks
    )

    post.image.attach(sample_image_blob)
    post.attachments.attach([sample_image_blob, sample_avatar_blob])

    post.update(body: ActionText::Content.new(FFaker::Lorem.paragraphs.join("\n\n")))

    3.times do
      post.comments.create!(
        user: User.all.sample,
        body: FFaker::Lorem.paragraph
      )
    end
  end
end

5.times do
  habtm = Habtm.create!(name: FFaker::Lorem.word)
  User.all.sample(10).each do |user|
    user.habtms << habtm
  end
end

User.all.each do |user|
  user.avatar.attach(sample_avatar_blob)
end

10.times do
  create_inbound_email_from_mail do |mail|
    mail.to "recipient@example.com"
    mail.from "sender@example.com"
    mail.subject FFaker::Lorem.sentence

    mail.text_part do |part|
      part.body FFaker::Lorem.paragraph
    end

    mail.html_part do |part|
      part.body "<p>#{FFaker::Lorem.paragraph}</p>"
    end
  end
end