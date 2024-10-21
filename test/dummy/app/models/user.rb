class User < ApplicationRecord
  has_many :connected_accounts, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_and_belongs_to_many :habtms, join_table: :user_habtms, dependent: :destroy

  has_one_attached :avatar
  has_person_name
  has_secure_password
  has_secure_token

  if Rails.gem_version >= Gem::Version.new("7.0.0.alpha")
    encrypts :ssn
  end

  store :preferences, accessors: [:language, :notifications], coder: JSON
  store_accessor :settings, [:weekly_email, :monthly_newsletter]

  attribute :virtual_attribute, default: "virtual"

  accepts_nested_attributes_for :posts, allow_destroy: true

  def something
    "Something"
  end
end
