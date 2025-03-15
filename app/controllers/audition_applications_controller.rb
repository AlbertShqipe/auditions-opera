class AuditionApplicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin, only: [:index, :show, :destroy]
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
    @applications = AuditionApplication.where.not(status: "rejected")
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

  def update
    @application = AuditionApplication.find(params[:id])

    if @application.update(application_params) # This will handle updating the status along with other attributes
      redirect_to audition_applications_path, notice: "Application updated!"
    else
      redirect_to audition_applications_path, alert: "Failed to update the application."
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
    redirect_to auditions_path, alert: "Application not found" if @application.nil?
  end

  def application_params
    params.require(:audition_application).permit(:first_name, :last_name, :date_of_birth, :nationality, :height, :gender, :video_link, :cv, :profile_image, :status)
  end

  def check_admin
    redirect_to root_path, alert: "Access denied!" unless current_user&.admin?
  end
end
