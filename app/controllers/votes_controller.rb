class VotesController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin

  def create
    Rails.logger.debug "Received audition_application_id: #{params[:audition_application_id]}"
    Rails.logger.debug "Received vote value: #{params[:value]}"

    @application = AuditionApplication.find(params[:audition_application_id])
    @applications = AuditionApplication.all
    @admin = current_user # Assuming the current user is an admin
    @audition_applications = AuditionApplication.all
    @admins = User.where(role: :admin)


    # Ensure only admin can vote
    unless @admin.admin?
      redirect_to audition_applications_path, alert: "You are not authorized to vote." and return
    end


    @vote = Vote.find_or_initialize_by(user: @admin, audition_application: @application)
    @vote.vote_value = Vote.vote_values[params[:value]]


    if @vote.save
      # Regenerate votes after saving
      votes = Vote.where(user_id: @admins.pluck(:id), audition_application_id: @applications.pluck(:id))
      votes_lookup = votes.index_by { |v| [v.audition_application_id, v.user_id] }
      @votes = @applications.each_with_object({}) do |application, hash|
        hash[application.id] = @admins.each_with_object({}) do |admin, inner_hash|
          inner_hash[admin.email] = votes_lookup[[application.id, admin.id]]&.vote_value || "not_set"
        end
      end
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("vote_#{@application.id}",
                                          partial: "votes/vote_status",
                                          locals: { vote: @vote, application: @application, votes: @votes })
        end
        format.html { redirect_to audition_applications_path, notice: "Vote cast successfully." }
      end
    else
      respond_to do |format|
        format.html { redirect_to audition_applications_path, alert: "Vote failed." }
        format.turbo_stream
      end
    end
  end

  private

  def check_admin
    redirect_to root_path, alert: "Access denied!" unless current_user.admin?
  end
end
