class AuditionApplication < ApplicationRecord
  belongs_to :user
  belongs_to :ethnicity, optional: true

  has_many :votes, dependent: :destroy
  has_one_attached :cv
  has_one_attached :profile_image

  before_create :set_default_ethnicity
  after_update :send_status_update_email

  enum gender: { male: "male", female: "female", other: "other", non_binary: "non-binary" }
  enum status: { pending: 0, accepted: 1, rejected: 2 }

  validates :first_name, :last_name, :date_of_birth, :address, :nationality, :height, :gender, presence: true
  validates :height, numericality: { greater_than: 0 }, allow_nil: true
  validates :video_link, format: { with: /\Ahttps?:\/\/.+\z/, message: "must be a valid URL" }, allow_blank: true

  include PgSearch::Model
  pg_search_scope :search_by_first_name_and_last_name,
  against: [:first_name, :last_name],
  using: { trigram: { threshold: 0.001 } }

  private

  def set_default_ethnicity
    self.ethnicity ||= Ethnicity.find_by(name: "Unknown")
  end

  def send_status_update_email
    if saved_change_to_status? && (accepted? || rejected?)
      AuditionApplicationMailer.status_update(self).deliver_now
    end
  end
end
