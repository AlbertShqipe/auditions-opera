class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :audition_application

  enum vote_value: { not_set: 0, yes: 1, maybe: 2, no: 3, star: 4 }, _default: :not_set

  validates :user_id, uniqueness: { scope: :audition_application_id, message: "You have already voted for this application" }
end
