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
    if params[:status_published].present?
      value = string_to_boolean(params[:status_published])
      base_query = base_query.where(status_published: value)
    end

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

  def rapport
    @applications = AuditionApplication.all

    # Users count (if User table is relevant)
    @total_users = User.count
    @total_applications = @applications.count

    # Age stats
    ages = @applications.map(&:age).compact
    @min_age = ages.min
    @max_age = ages.max
    @avg_age = (ages.sum / ages.size.to_f).round(1) if ages.any?

    # Height stats
    heights = @applications.map(&:height).compact
    @min_height = heights.min
    @max_height = heights.max
    @avg_height = (heights.sum / heights.size.to_f).round(1) if heights.any?

    # Gender breakdown
    @gender_counts = @applications.group(:gender).count

    # Nationality diversity
    @nationality_count = @applications.select(:nationality).distinct.count
    @nationalities = @applications.select(:nationality).distinct.pluck(:nationality)

    # Tallest and shortest applicants
    @tallest = @applications.where.not(height: nil).order(height: :desc).first
    @shortest = @applications.where.not(height: nil).order(height: :asc).first

    @accepted = @applications.where(status: "accepted").count
    @rejected = @applications.where(status: "rejected").count
  end

  def download_rapport
    @applications = AuditionApplication.all

    # same stats logic as you already have...
    @total_users = User.count
    @total_applications = @applications.count

    ages = @applications.map(&:age).compact
    @min_age = ages.min
    @max_age = ages.max
    @avg_age = (ages.sum / ages.size.to_f).round(1) if ages.any?

    heights = @applications.map(&:height).compact
    @min_height = heights.min
    @max_height = heights.max
    @avg_height = (heights.sum / heights.size.to_f).round(1) if heights.any?

    @gender_counts = @applications.group(:gender).count
    @nationality_count = @applications.select(:nationality).distinct.count
    @nationalities = @applications.select(:nationality).distinct.pluck(:nationality)
    @tallest = @applications.where.not(height: nil).order(height: :desc).first
    @shortest = @applications.where.not(height: nil).order(height: :asc).first
    @accepted = @applications.where(status: "accepted").count
    @rejected = @applications.where(status: "rejected").count


    pdf = Prawn::Document.new

    # Path to the font file (make sure it matches your directory)
    font_path = Rails.root.join("app/assets/fonts/DejaVuSans.ttf")

    # Register and set as the default font
    pdf.font_families.update("DejaVuSans" => {
      normal: Rails.root.join("app/assets/fonts/DejaVuSans.ttf"),
      bold: Rails.root.join("app/assets/fonts/DejaVuSans-Bold.ttf")
    })

    pdf.font "DejaVuSans"

    pdf.fill_color "000000"
    pdf.fill_rectangle [0, pdf.cursor], pdf.bounds.width, 30

    # Banner dimensions
    banner_height = 100

    # Draw black rectangle as banner background
    pdf.fill_color "000000"
    pdf.fill_rectangle [0, pdf.cursor], pdf.bounds.width, banner_height

    # Insert logo inside the banner
    logo_path = Rails.root.join("app/assets/images/logo-audition.png")
    if File.exist?(logo_path)
      # Estimate vertical alignment
      y_position = pdf.cursor - (banner_height / 2) + 40 # adjust as needed

      pdf.image logo_path,
        width: 150,
        position: :left,
        at: [pdf.bounds.width / 2 - 50, y_position]
    end


    # Reset fill color back to black (for text below)
    pdf.fill_color "000000"
    pdf.move_down banner_height + 10

    pdf.text "Audition Report", size: 16, style: :bold, align: :center
    pdf.move_down 10

    summary_paragraph = <<~TEXT
      This audition cycle received a total of #{@total_applications} applications from #{@nationality_count} different nationalities, reflecting a strong international interest. A total of #{@total_users} users participated in the process.

      The age range of applicants spans from #{@min_age} to #{@max_age} years old, with an average age of #{@avg_age} years. In terms of height, the shortest applicant is #{@min_height} m, while the tallest is #{@max_height} m. The average height across all candidates is #{@avg_height} m.

      Gender representation among applicants includes:
      #{@gender_counts.map { |gender, count| "#{count} #{gender.pluralize(count)}" }.to_sentence}.

      Out of all submissions, #{@accepted} have been invited to the audition.

    TEXT


    pdf.text summary_paragraph.strip, size: 9, leading: 2
    summary_data = [
      ["Category", "Value"],
      ["Total Users", @total_users],
      ["Total Applications", @total_applications],
      ["Youngest Age", "#{@min_age} years"],
      ["Oldest Age", "#{@max_age} years"],
      ["Average Age", "#{@avg_age} years"],
      ["Shortest", "#{@shortest&.full_name} (#{@min_height} cm)"],
      ["Tallest", "#{@tallest&.full_name} (#{@max_height} cm)"],
      ["Average Height", "#{@avg_height} cm"],
      ["Number of Nationalities", @nationality_count],
      ["Accepted", @accepted]
    ]

    # Estimate your table width
    table_width = 400 # adjust as needed depending on content length

    # Center the table
    x_position = (pdf.bounds.width - table_width) / 2

    pdf.move_down 30
    pdf.text "Audition Statistics", size: 8, style: :bold, align: :center
    pdf.move_down 5

    pdf.bounding_box([x_position, pdf.cursor], width: table_width) do
      pdf.table(summary_data, header: true, row_colors: ["F0F0F0", "FFFFFF"],
        cell_style: { size: 9, padding: [4, 8] }, width: table_width)
    end
    pdf.move_down 105

    pdf.text "This report was generated on #{Date.today.strftime('%B %d, %Y')}", align: :right, size: 7

    # === Footer with black bar, centered logo, and date ===
    pdf.bounding_box([0, 50], width: pdf.bounds.width, height: 40) do
      # Draw black footer bar
      pdf.fill_color "000000"
      pdf.fill_rectangle [0, 40], pdf.bounds.width, 60

      # Insert centered logo if available
      logo1_path = Rails.root.join("app/assets/images/apple-touch-icon.png")
      if File.exist?(logo1_path)
        pdf.image logo1_path,
          width: 30,
          at: [pdf.bounds.width / 2 - 15, 32] # adjust position
      end

      # Insert date text to the right of the logo
      pdf.fill_color "ffffff"
      pdf.text_box "Opéra National de Lyon",
        at: [pdf.bounds.width / 2 - 50, 20], # adjust position
        width: 200,
        height: 40,
        size: 9,
        align: :left,
        valign: :center

      # Reset fill color
      pdf.fill_color "000000"
    end

    send_data pdf.render,
              filename: "audition_rapport.pdf",
              type: "application/pdf",
              disposition: "inline"
  end

  private

  def string_to_boolean(param)
    param.to_s.strip.downcase == "true"
  end

  def check_admin
    redirect_to root_path, alert: t("controllers.audition_application.check_admin") unless current_user&.admin? || current_user&.director? || current_user&.guest?
  end
end
