class AuditionApplication < ApplicationRecord
  belongs_to :user

  has_one_attached :cv
  has_one_attached :profile_image

  enum gender: { male: "male", female: "female", other: "other", non_binary: "non_binary" }
  enum status: { pending: 0, accepted: 1, rejected: 2 }

  validates :first_name, :last_name, :date_of_birth, :nationality, :height, :gender, presence: true
  validates :height, numericality: { greater_than: 0 }, allow_nil: true
  validates :video_link, format: { with: /\Ahttps?:\/\/.+\z/, message: "must be a valid URL" }, allow_blank: true
end
