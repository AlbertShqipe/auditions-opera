class AuditionApplication < ApplicationRecord
  belongs_to :user

  has_one_attached :cv
  has_one_attached :profile_image
  after_update :send_status_update_email

  enum gender: { male: "male", female: "female", other: "other", non_binary: "non_binary" }
  enum status: { pending: 0, accepted: 1, rejected: 2 }

  validates :first_name, :last_name, :date_of_birth, :nationality, :height, :gender, presence: true
  validates :height, numericality: { greater_than: 0 }, allow_nil: true
  validates :video_link, format: { with: /\Ahttps?:\/\/.+\z/, message: "must be a valid URL" }, allow_blank: true


  private

  def send_status_update_email
    if saved_change_to_status? && (accepted? || rejected?)
      AuditionApplicationMailer.status_update(self).deliver_now
    end
  end
end
