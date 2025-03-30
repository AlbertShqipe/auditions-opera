class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin
  def index
    @applications = AuditionApplication.includes(:user, :ethnicity, :votes, :gender, :nationality, :address, :confirmed_attendance)
  end

  def data
    applications = AuditionApplication.includes(:ethnicity, :votes).map do |app|
      {
        id: app.id,
        name: app.first_name + ' ' + app.last_name,
        nationality: app.nationality,
        gender: app.gender,
        application_status: app.status,
        ethnicity: app.ethnicity&.name || "N/A",
        votes_count: app.votes.map { |vote|
          {
            user_id: vote.user_id,
            vote_value: vote.vote_value,
            created_at: vote.created_at
          }
        },
        email: app.user.email,
        video_link: app.video_link,
        cv: app.cv.attached? ? url_for(app.cv) : nil,
        confirmed_attendance: app.confirmed_attendance
      }
    end

    render json: { data: applications }, status: :ok
  end

  private

  def check_admin
    redirect_to root_path, alert: "Access denied!" unless current_user&.admin? || current_user&.director?
  end
end
