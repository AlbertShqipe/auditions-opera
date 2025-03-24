class AuditionApplicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin, only: [:index, :destroy]
  before_action :set_application, only: [:show, :update_status]

  def update_status
    # Log the status to make sure it is coming through
    Rails.logger.debug "Received status: #{params[:status]}"

    if @application.update(status: params[:status])
      redirect_to @application, notice: "Status updated to #{params[:status].humanize}."
    else
      redirect_to @application, alert: "Failed to update status."
    end
  end

  def index
    # Search logic (if query is provided)
    if params[:query].present?
      @applications = AuditionApplication.search_by_first_name_and_last_name(params[:query])
    else
      @applications = AuditionApplication.all
    end

    # Status, gender, and vote filter params
    @statuses = AuditionApplication.statuses.keys
    @selected_status = params[:status]
    @selected_gender = params[:gender]
    @selected_age = params[:age]
    @selected_vote = params[:vote]

    # Initialize filtered applications based on search results or all applications if no search
    @audition_applications = @applications

    # Apply status filter if selected
    @audition_applications = @audition_applications.where(status: @selected_status) if @selected_status.present?

    # Apply gender filter if selected
    @audition_applications = @audition_applications.where(gender: @selected_gender) if @selected_gender.present?

    # Fetch all admins
    @admins = User.where(role: [:admin, :director])

    # Filter by votes if selected
    if @selected_vote.present?
      # Fetch votes based on the current user's ID and selected vote status
      @audition_applications = @audition_applications.joins(:votes)
                                                   .where(votes: { user_id: current_user.id, vote_value: @selected_vote })
    end

    # Fetch votes related to the filtered applications and admins
    votes = Vote.where(user_id: @admins.pluck(:id), audition_application_id: @audition_applications.pluck(:id))

    # Create a lookup hash for votes: { [audition_application_id, user_id] => vote_value }
    votes_lookup = votes.index_by { |v| [v.audition_application_id, v.user_id] }

    # Structure the votes data: { audition_application_id => { admin_email => vote_value } }
    @votes = @audition_applications.each_with_object({}) do |application, hash|
      hash[application.id] = @admins.each_with_object({}) do |admin, inner_hash|
        inner_hash[admin.email] = votes_lookup[[application.id, admin.id]]&.vote_value || "not_set"
      end
    end
  end

  def show
    @application = AuditionApplication.find(params[:id])
    @ethnicities = Ethnicity.all
    # raise
  end

  def new
    @application = AuditionApplication.new
  end

  def create
    Rails.logger.debug("Params: #{params.inspect}")
    @application = current_user.audition_applications.build(application_params)
    @application.status = "pending"

    if @application.save
      if current_user.admin? || current_user.director?
        redirect_to audition_applications_path, notice: "Application submitted successfully!"
      else
        redirect_to root_path, notice: "Application submitted successfully!"
      end
    else
      render :new, alert: "Something went wrong. Please check the form and try again."
    end
  end

  def edit
    @application = AuditionApplication.find(params[:id])
  end

  def update
    @application = AuditionApplication.find(params[:id])
    previous_status = @application.status # Store the previous status

    if @application.update(application_params) # This will handle updating the status along with other attributes
      redirect_to audition_application_path, notice: "Application updated!"
    else
      redirect_to audition_application_path, alert: "Failed to update the application. Contact support."
    end
  end

  def destroy
    @application = AuditionApplication.find(params[:id])
    @application.destroy
    redirect_to audition_applications_path, notice: "Application deleted."
  end

  def update_ethnicity
    if @application.update(ethnicity_params)
      redirect_to @application, notice: "Ethnicity updated successfully."
    else
      redirect_to @application, alert: "Failed to update ethnicity."
    end
  end

  private

  def set_application
    @application = AuditionApplication.find_by(id: params[:id])
    redirect_to audition_applications_path, alert: "Application not found" if @application.nil?
  end

  def application_params
    params.require(:audition_application).permit(:first_name, :last_name, :date_of_birth, :height, :gender, :address, :nationality,:video_link, :cv, :profile_image, :status, :ethnicity_id)
  end

  def ethnicity_params
    params.require(:audition_application).permit(:ethnicity_id)
  end


  def check_admin
    redirect_to root_path, alert: "Access denied!" unless current_user&.admin? || current_user&.director?
  end
end
