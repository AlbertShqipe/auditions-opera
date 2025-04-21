class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin

  def index
  # Fetch all admins
  @admins = User.where(role: [:admin, :director, :guest])
  @audition_applications = AuditionApplication.all

  # Fetch votes related to the filtered applications and admins
  votes = Vote.where(user_id: @admins.pluck(:id), audition_application_id: @audition_applications.pluck(:id))

  # Create a lookup hash for votes: { [audition_application_id, user_id] => vote_value }
  votes_lookup = votes.index_by { |v| [v.audition_application_id, v.user_id] }
  @votes = @audition_applications.each_with_object({}) do |application, hash|
    hash[application.id] = @admins.each_with_object({}) do |admin, inner_hash|
      inner_hash[admin.email] = votes_lookup[[application.id, admin.id]]&.vote_value || "not_set"
    end
  end

  # ✅ Start with a base query before grouping
  base_query = AuditionApplication.left_joins(:votes)

  # ✅ Apply filters BEFORE group/order
  base_query = base_query.where(status: params[:status]) if params[:status].present?
  base_query = base_query.where(vote_result: params[:vote_result]) if params[:vote_result].present?

  # ✅ Apply select, group, and order after filters
  @applications = base_query
                    .select("audition_applications.*")
                    .group("audition_applications.id")
                    .order(Arel.sql("MAX(votes.vote_value) DESC NULLS LAST"))


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
      yes_count = app.votes.where(vote_value: "yes").count
      maybe_count = app.votes.where(vote_value: "maybe").count
      no_count = app.votes.where(vote_value: "no").count
      star_count = app.votes.where(vote_value: "star").count

      gender_labels = {
        "male" => "Male",
        "female" => "Woman",
        "non_binary" => "Non-binary",
        "other" => "Other"
      }

      {
        id: app.id,
        name: app.first_name + ' ' + app.last_name,
        nationality: app.nationality,
        gender: gender_labels[app.gender] || app.gender.capitalize,
        application_status: app.status,
        # ethnicity: app.ethnicity&.name || "N/A",
        votes_count: app.votes.map { |vote|
          {
            user_id: vote.user_id,
            vote_value: vote.vote_value,
          }
        },
        result: app.vote_result,
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
    redirect_to root_path, alert: t("controllers.audition_application.check_admin") unless current_user&.admin? || current_user&.director? || current_user&.guest?
  end
end
