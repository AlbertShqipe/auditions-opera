class AuditionApplicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin, only: [:index]
  before_action :set_application, only: [:show, :update_status]
  before_action :set_application, only: [:confirm_attendance, :update_attendance]
  before_action :authorize_candidate, only: [:confirm_attendance]

  def send_results
    # Select applications that are either accepted or rejected and their status is not published
    applications = AuditionApplication.where(status: ["accepted", "rejected"], status_published: [false, nil])
    count = applications.count

    # Send emails to all selected applications about their status change
    applications.find_each do |application|
      AuditionMailer.status_update(application).deliver_now
      application.update(status_published: true)
    end

    redirect_to audition_applications_path, notice: "Results sent to #{count} candidates."
  end

  def confirm_attendance
    # Check if the application is accepted and not already confirmed for attendance
    if @application.accepted? && !@application.confirmed_attendance
      flash[:notice] = t("controllers.audition_application.confirm_attendance.success")
      render :confirm_attendance
    else
      redirect_to audition_application_path(@application), alert: t("controllers.audition_application.confirm_attendance.error")
    end
  end

  def confirm_attendance_message
    # The candidate that is accepted has the chance to contact the admin in case of inability to attend the audition
    name = params[:name]
    email = params[:email]
    message = params[:message]

    AuditionMailer.contact_message(name, email, message).deliver_now

    flash[:notice] = t("controllers.audition_application.confirm_attendance_message")
    redirect_to audition_application_path(params[:id])
  end

  def update_attendance
    # Check if the application is accepted and not already confirmed for attendance
    if @application.update(confirmed_attendance: true)
      redirect_to audition_application_path(@application), notice: t("controllers.audition_application.update_attendance.success")
    else
      redirect_to audition_application_path(@application), alert: t("controllers.audition_application.update_attendance.error")
    end
  end

  # def update_status
  #   # Log the status to make sure it is coming through
  #   Rails.logger.debug "Received status: #{params[:status]}"

  #   if @application.update(status: params[:status])
  #     redirect_to @application, notice: t("controllers.audition_application.update_status.success", status: params[:status].humanize)
  #     # AuditionMailer.status_update_email(@application).deliver_now
  #   else
  #     redirect_to @application, alert: t("controllers.audition_application.update_status.error")
  #   end
  # end

  def index
    # Search logic (if query is provided)
    if params[:query].present?
      @applications = AuditionApplication.search_by_first_name_and_last_name(params[:query])
    else
      @applications = AuditionApplication.all
    end

    # Status, gender, and vote filter params
    # @statuses = AuditionApplication.statuses.keys
    # @selected_status = params[:status]
    @selected_gender = params[:gender]
    # @selected_age = params[:age]
    @selected_vote = params[:vote]

    # Initialize filtered applications based on search results or all applications if no search
    @audition_applications = @applications

    # # Apply status filter if selected
    # @audition_applications = @audition_applications.where(status: @selected_status) if @selected_status.present?

    # Apply gender filter if selected
    @audition_applications = @audition_applications.where(gender: @selected_gender) if @selected_gender.present?

    # Fetch all admins
    @admins = User.where(role: [:admin, :director])

    # Filter by votes if selected
    if @selected_vote.present?
      if @selected_vote == "not set"
        @audition_applications = @audition_applications
          .left_joins(:votes)
          .where("votes.user_id IS NULL OR (votes.user_id = ? AND votes.vote_value = ?)", current_user.id, 0)
      else
        vote_mapping = {
          "yes" => 1,
          "maybe" => 2,
          "no" => 3,
          "star" => 4
        }
        vote_value = vote_mapping[@selected_vote]

        @audition_applications = @audition_applications
          .joins(:votes)
          .where(votes: { user_id: current_user.id, vote_value: vote_value })
      end
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
    @application = AuditionApplication.find_by(id: params[:id])

    if @application
      @ethnicities = Ethnicity.all
    else
      redirect_to audition_applications_path, alert: t("controllers.audition_application.show.error")
    end
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
      redirect_to root_path, notice: t("controllers.audition_application.create.success")

      # Notify the user about the application submission
      AuditionMailer.confirmation_email(@application).deliver_now

      # Notify the admin about the number of applications every 10 applications
      auditions = AuditionApplication.all.count
      if auditions % 10 == 0
        record = AdminNotification.find_or_initialize_by(kind: "application_milestone")
        last_notified = record.value || 0

        if auditions > last_notified
          AuditionMailer.admin_email.deliver_now # Use deliver_later for safety with bulk
          record.update(value: auditions)
        end
      end
    else
      flash[:alert] = t("controllers.audition_application.create.error")
      render :new
    end
  end

  def edit
    @application = AuditionApplication.find(params[:id])
  end

  def update
    @audition_application = AuditionApplication.find(params[:id])
    previous_status = @audition_application.status # Store the previous status


    if params[:audition_application_status].present?
      # Only updating status
      if @audition_application.update(status: params[:audition_application_status])
        # flash[:notice] = t("controllers.audition_application.update.success")
      else
        # flash[:alert] = t("controllers.audition_application.update.error")
      end
    else
      # Normal update with full application_params
      if @audition_application.update(application_params)
        redirect_to audition_application_path(@audition_application), notice: t("controllers.audition_application.update.success")
      else
        redirect_to audition_application_path(@audition_application), alert: t("controllers.audition_application.update.error")
      end
    end
  end

  def destroy
    @application = AuditionApplication.find(params[:id])

    if @application.user == current_user
      @application.destroy
      redirect_to audition_applications_path, notice: t("controllers.audition_application.destroy.success")
    else
      redirect_to audition_applications_path, alert: t("controllers.audition_application.destroy.error")
    end
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
    @application = current_user.audition_applications.find(params[:id])
  end

  def authorize_candidate
    unless current_user.candidate?
      redirect_to root_path, alert: t("controllers.audition_application.authorize_candidate.error")
    end
  end

  def set_application
    @application = AuditionApplication.find_by(id: params[:id])
    redirect_to audition_applications_path, alert: t("controllers.audition_application.set_application.not_found") if @application.nil?
  end

  def application_params
    params.require(:audition_application).permit(:first_name, :last_name, :date_of_birth, :height, :gender, :address, :nationality,:video_link, :cv, :profile_image, :status, :ethnicity_id)
  end

  def ethnicity_params
    params.require(:audition_application).permit(:ethnicity_id)
  end


  def check_admin
    redirect_to root_path, alert: t("controllers.audition_application.check_admin") unless current_user&.admin? || current_user&.director? || current_user&.guest?
  end
end
