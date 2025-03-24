class Ethnicity < ApplicationRecord
  has_many :audition_applications

  # Validate that the name is included in the allowed list and is unique
  validates :name, presence: true, uniqueness: true, inclusion: { in: ["Caucasian", "Asian", "Black", "Other"] }
end
