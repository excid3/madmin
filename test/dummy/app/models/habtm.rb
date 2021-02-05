class Habtm < ApplicationRecord
  has_and_belongs_to_many :users, join_table: :user_habtms
end
