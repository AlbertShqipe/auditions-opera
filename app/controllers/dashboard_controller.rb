class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin

  def index
    vote_mapping = {
      "not set" => nil,
      "yes" => 1,
      "maybe" => 2,
      "star" => 5,
      "no" => 3
    }
    vote_value = vote_mapping[params[:vote]]

    # Select only the votes of the current_user
    @applications = AuditionApplication
                      .select("audition_applications.*") # Only distinct applications
                      .left_joins(:votes)
                      .where("votes.user_id = ? OR votes.user_id IS NULL", current_user.id) # Filter votes by current_user
                      .group("audition_applications.id")
                      .order(Arel.sql("MAX(votes.vote_value) DESC NULLS LAST")) # Sort by highest vote value

    # Apply vote filter if selected
    if params[:vote].present? && params[:vote] != ""
      if vote_value.nil?
        @applications = @applications.having("MAX(votes.vote_value) IS NULL OR MAX(votes.vote_value) = 0")
      else
        @applications = @applications.having("MAX(votes.vote_value) = ?", vote_value)
      end
    end

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
          }
        },
        result: evaluate_votes(yes_count, maybe_count, no_count, star_count),
        email: app.user.email,
        video_link: app.video_link,
        cv: app.cv.attached? ? url_for(app.cv) : nil,
        confirmed_attendance: app.confirmed_attendance
      }
    end

    render json: { data: applications }, status: :ok
  end

  private

  # Method to evaluate the result based on the vote counts
  # def evaluate_votes(yes_count, maybe_count, no_count, star_count)
  #   # If there's any 'star' vote, return 'YES'
  #   return "OUI" if star_count > 0

  #   # Specific vote combinations
  #   if yes_count >= 2 && maybe_count == 0 && no_count == 0
  #     return "OUI" # All 'YES' votes
  #   elsif maybe_count >= 2 && no_count == 0
  #     return "MAYBE+" # More 'MAYBE' votes than 'YES' and 'NO'
  #   elsif yes_count >= 1 && maybe_count >= 1 && no_count == 0
  #     return "MAYBE" # Some 'YES' and 'MAYBE' votes, but no 'NO' votes
  #   elsif no_count >= 2
  #     return "NON" # More 'NO' votes than 'YES' and 'MAYBE'
  #   elsif yes_count == 0 && maybe_count == 0 && no_count == 0
  #     return "INCONNU" # All votes are zero, return 'INCONNU'
  #   end

  #   # Default fallback in case no condition is met
  #   return "INCONNU"
  # end
  def evaluate_votes(yes_count, maybe_count, no_count, star_count)
    # If there is any "star" vote, return "YES"
    if star_count > 0
      return "YES ⭐️"
    end

    # Check conditions and return the corresponding result
    if yes_count == 3
      return "OUI ✅"
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
      return "NON 🔴"
    elsif (no_count == 3 )
      return "NON 🔴"
    else
      return "INCONNU ❓"
    end
  end

  def check_admin
    redirect_to root_path, alert: "Access denied!" unless current_user&.admin? || current_user&.director?
  end
end
