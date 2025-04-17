class AuditionApplication < ApplicationRecord
  belongs_to :user
  belongs_to :ethnicity, optional: true

  has_many :votes, dependent: :destroy
  has_one_attached :cv
  has_one_attached :profile_image

  before_create :set_default_ethnicity
  # after_update :send_status_update_email
  after_initialize :set_default_vote_result, if: :new_record?

  enum gender: { female: "female", male: "male", non_binary: "non_binary", other: "other" }
  enum status: { pending: 0, accepted: 1, rejected: 2 }

  validates :first_name, :last_name, :date_of_birth, :address, :nationality, :height, :gender, :video_link, :profile_image, :cv, presence: true
  validates :height, numericality: { greater_than: 0 }, allow_nil: true
  validates :video_link, format: { with: /\Ahttps?:\/\/.+\z/, message: "must be a valid URL" }, allow_blank: true

  include PgSearch::Model
  pg_search_scope :search_by_first_name_and_last_name,
  against: [:first_name, :last_name],
  using: { trigram: { threshold: 0.001 } }

  def self.localized_genders
    genders.keys.map do |key|
      [I18n.t("audition_form.form.gender_collection.#{key}", default: key.humanize), key]
    end
  end

  def update_vote_result!
    counts = votes.group(:vote_value).count

    yes_count = counts['yes'] || 0
    maybe_count = counts['maybe'] || 0
    no_count = counts['no'] || 0
    star_count = counts['star'] || 0

    self.vote_result = evaluate_votes(yes_count, maybe_count, no_count, star_count)
    save!
  end

  private

  def evaluate_votes(yes_count, maybe_count, no_count, star_count)
    if star_count > 0
      return "YES ⭐️"
    end

    if yes_count == 3
      return "YES ✅"
    elsif (yes_count == 1 && maybe_count == 2) ||
          (yes_count == 2 && maybe_count == 1) ||
          (yes_count == 1 && maybe_count == 1 && no_count == 1) ||
          (yes_count == 2 && no_count == 1)
      return "MAYBE+ 🟡"
    elsif (yes_count == 1 && no_count == 2) ||
          maybe_count == 3 ||
          (maybe_count == 2 && no_count == 1)
      return "MAYBE 🟠"
    elsif maybe_count == 1 && no_count == 2
      return "NO 🔴"
    elsif no_count == 3
      return "NO 🔴"
    else
      return "UNKNOWN ❓"
    end
  end

  def set_default_vote_result
    self.vote_result ||= "UNKNOWN ❓"
  end

  def set_default_ethnicity
    self.ethnicity ||= Ethnicity.find_by(name: "Unknown")
  end

  # def send_status_update_email
  #   if saved_change_to_status? && (accepted? || rejected?)
  #     AuditionApplicationMailer.status_update(self).deliver_now
  #   end
  # end
end
