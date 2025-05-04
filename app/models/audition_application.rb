class AuditionApplication < ApplicationRecord
  belongs_to :user
  belongs_to :ethnicity, optional: true

  has_many :votes, dependent: :destroy
  has_one_attached :cv
  has_one_attached :profile_image

  before_create :set_default_ethnicity
  after_initialize :set_default_vote_result, if: :new_record?
  after_create :initialize_votes
  after_create :set_default_status_published
  # after_update :send_status_update_email

  enum gender: { female: "female", male: "male", non_binary: "non_binary", other: "other" }
  enum status: { pending: 0, accepted: 1, rejected: 2 }

  before_validation :normalize_video_link

  validates :first_name, :last_name, :date_of_birth, :address, :nationality, :height, :gender, :video_link, :profile_image, :cv, presence: true
  validates :height, numericality: { greater_than: 0 }, allow_nil: true
  validates :video_link, format: { with: %r{\Ahttps:\/\/(www\.)?(youtube\.com|youtu\.be)\/},
  message: "must be a valid YouTube link starting with https://"}
  validate :validate_cv_attachment
  validate :validate_profile_image_attachment

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

  def age
    return unless date_of_birth
    now = Time.zone.now
    now.year - date_of_birth.year - ((now.month > date_of_birth.month || (now.month == date_of_birth.month && now.day >= date_of_birth.day)) ? 0 : 1)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def validate_cv_attachment
    return unless cv.attached?
    unless cv.content_type.in?(%w(application/pdf))
      errors.add(:cv, "must be a PDF file")
    end
    if cv.byte_size > 5.megabytes
      errors.add(:cv, "should be less than 5MB")
    end
  end

  def validate_profile_image_attachment
    return unless profile_image.attached?
    unless profile_image.content_type.in?(%w(image/jpeg image/png image/webp))
      errors.add(:profile_image, "must be JPG, PNG, or WebP")
    end
    if profile_image.byte_size > 5.megabytes
      errors.add(:profile_image, "should be less than 5MB")
    end
  end

  def initialize_votes
    # Find all admins and directors
    admins_and_directors = User.where(role: [:admin, :director])

    # Create a vote for each admin/director with default not_set
    admins_and_directors.each do |user|
      votes.create!(user: user, vote_value: :not_set)
    end
  end

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

  def set_default_status_published
    update_column(:status_published, false) if status_published.nil?
  end

  def normalize_video_link
    if video_link.present? && !video_link.start_with?("https://")
      self.video_link = "https://#{video_link}"
    end
  end

  # def send_status_update_email
  #   if saved_change_to_status? && (accepted? || rejected?)
  #     AuditionApplicationMailer.status_update(self).deliver_now
  #   end
  # end
end
