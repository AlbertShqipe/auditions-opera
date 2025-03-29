class AuditionApplicationMailer < ApplicationMailer
  def status_update(application)
    @application = application
    mail(to: @application.user.email, subject:
          if @application.status == "accepted"
            "Congratulations! Your Audition Application Has Been Accepted"
          else
            "Thank You for Your Application – Audition Update"
          end
        )
  end
end
