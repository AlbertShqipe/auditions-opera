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
    @applications = AuditionApplication.all
    @statuses = AuditionApplication.statuses.keys
    @selected_status = params[:status]
    @audition_applications = if @selected_status.present?
                              AuditionApplication.where(status: @selected_status)
                            else
                              AuditionApplication.all
                            end


    @admins = User.where(role: :admin)



    # Fetch all votes from admins in one query
    votes = Vote.where(user_id: @admins.pluck(:id), audition_application_id: @applications.pluck(:id))

    # Transform votes into a lookup hash: { [audition_application_id, user_id] => vote_value }
    votes_lookup = votes.index_by { |v| [v.audition_application_id, v.user_id] }

    # Create a structured hash: { audition_application_id => { admin_email => vote_value } }
    @votes = @audition_applications.each_with_object({}) do |application, hash|
      hash[application.id] = @admins.each_with_object({}) do |admin, inner_hash|
        inner_hash[admin.email] = votes_lookup[[application.id, admin.id]]&.vote_value || "not_set"
      end
    end

  end

  def show
    @application = AuditionApplication.find(params[:id])
  end

  def new
    @application = AuditionApplication.new
  end

  def create
    Rails.logger.debug("Params: #{params.inspect}")
    @application = current_user.audition_applications.build(application_params)
    @application.status = "pending"

    if @application.save
      if current_user.admin?
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
      redirect_to root_path, notice: "Application updated!"
    else
      redirect_to root_path, alert: "Failed to update the application. Contact support."
    end
  end

  def destroy
    @application = AuditionApplication.find(params[:id])
    @application.destroy
    redirect_to audition_applications_path, notice: "Application deleted."
  end

  private

  def set_application
    @application = AuditionApplication.find_by(id: params[:id])
    redirect_to audition_applications_path, alert: "Application not found" if @application.nil?
  end

  def application_params
    params.require(:audition_application).permit(:first_name, :last_name, :date_of_birth, :height, :gender, :address, :nationality,:video_link, :cv, :profile_image, :status)
  end

  def check_admin
    redirect_to root_path, alert: "Access denied!" unless current_user&.admin?
  end
end
