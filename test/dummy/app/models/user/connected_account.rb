class User::ConnectedAccount < ApplicationRecord
  belongs_to :user
  validates :service, presence: true
end
