class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
  end

  def final_step
    @applications = AuditionApplication.all

    # Fetch all applications with different statuses
    @pending_applications = AuditionApplication.where(status: "pending")
    @rejected_applications = AuditionApplication.where(status: "rejected")
    @accepted_applications = AuditionApplication.where(status: "accepted")
  end

  def help
    @user_type = current_user.role.to_sym # Assumes roles like :admin, :director, :artist
  end

  private

  def check_admin
    redirect_to root_path, alert: t("controllers.audition_application.check_admin") unless current_user&.admin? || current_user&.director?
  end
end
