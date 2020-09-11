class User < ApplicationRecord
  has_many :posts
  has_many :comments

  has_person_name

  attribute :virtual_attribute
end
