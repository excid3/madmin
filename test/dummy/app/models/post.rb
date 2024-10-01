class Post < ApplicationRecord
  extend FriendlyId
  friendly_id :title
  has_paper_trail

  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy
  has_many_attached :attachments
  has_one_attached :image
  has_rich_text :body

  scope :recent, -> { where(created_at: 2.weeks.ago..) }

  enum :state, [:draft, :published, :archived]

  validates :title, presence: true
end
