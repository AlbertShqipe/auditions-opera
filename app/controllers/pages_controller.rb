class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home, :help ]

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
    @user_type = current_user&.role&.to_sym || :candidate
  end

  def invited_candidates
    @audition_applications = AuditionApplication.where(status: 'accepted', status_published: true)

    if params[:confirmed_attendance].present?
      case params[:confirmed_attendance]
      when "true"
        @audition_applications = @audition_applications.where(confirmed_attendance: true)
      when "false"
        @audition_applications = @audition_applications.where(confirmed_attendance: false)
      end
    end

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  private

  def check_admin
    redirect_to root_path, alert: t("controllers.audition_application.check_admin") unless current_user&.admin? || current_user&.director?
  end
end
