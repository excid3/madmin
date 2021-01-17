class User < ApplicationRecord
  has_many :posts
  has_many :comments
  has_and_belongs_to_many :habtms

  has_person_name

  attribute :virtual_attribute, default: "virtual"

  has_one_attached :avatar
end
