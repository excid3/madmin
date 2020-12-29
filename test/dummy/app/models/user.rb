class User < ApplicationRecord
  has_many :posts
  has_many :comments

  has_person_name

  attribute :virtual_attribute, default: "virtual"

  has_one_attached :avatar
end
