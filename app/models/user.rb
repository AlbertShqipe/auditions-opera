class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :validatable

  has_many :audition_applications, dependent: :destroy
  has_many :votes, dependent: :destroy

  enum role: { candidate: 0, admin: 1, guest: 2, director: 3 }

  # Set default role for new users
  after_initialize :set_default_role, if: :new_record?

  def set_default_role
    self.role ||= :candidate
  end
end
