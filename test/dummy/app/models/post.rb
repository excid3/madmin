class Post < ApplicationRecord
  extend FriendlyId
  friendly_id :title

  # Declared before the associations so it runs ahead of their dependent: :destroy
  before_destroy :ensure_unpublished

  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy
  has_many_attached :attachments
  has_one_attached :image
  has_rich_text :body

  scope :recent, -> { where(created_at: 2.weeks.ago..) }

  enum :state, [:draft, :published, :archived]

  validates :title, presence: true

  private

  def ensure_unpublished
    return unless published?

    errors.add(:base, :destroy_published)
    throw :abort
  end
end
