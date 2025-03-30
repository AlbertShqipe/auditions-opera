class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin

  def index
    @selected_vote = params[:vote]
    @applications = AuditionApplication.all

    if @selected_vote.present? && @selected_vote != ""
      vote_mapping = {
        "not set" => nil,
        "yes" => 1,
        "maybe" => 2,
        "star" => 5,
        "no" => 3
      }
      vote_value = vote_mapping[@selected_vote]

      if vote_value.nil?
        @applications = @applications.left_joins(:votes).where(votes: { vote_value: nil }).or(@applications.left_joins(:votes).where(votes: { vote_value: 0 }))
      else
        @applications = @applications.left_joins(:votes).where(votes: { vote_value: vote_value })
      end
    end

    @applications = @applications.left_joins(:votes).order(Arel.sql("CASE
      WHEN votes.vote_value IS NULL THEN 0
      WHEN votes.vote_value = 0 THEN 1
      WHEN votes.vote_value = 2 THEN 2
      WHEN votes.vote_value = 1 THEN 3
      WHEN votes.vote_value = 3 THEN 4
      ELSE 5
    END"))

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    @application = AuditionApplication.find(params[:id])

    respond_to do |format|
      format.html
      format.turbo_stream
    end
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
