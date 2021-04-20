class User < ApplicationRecord
  has_many :posts
  accepts_nested_attributes_for :posts, allow_destroy: true

  has_many :comments
  has_and_belongs_to_many :habtms, join_table: :user_habtms

  has_person_name

  attribute :virtual_attribute, default: "virtual"

  has_one_attached :avatar

  has_secure_password
  has_secure_token
end
