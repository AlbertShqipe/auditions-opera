class AuditionMailer < ApplicationMailer
  def confirmation_email(application)
    @application = application
    mail(
      to: @application.user.email,
      subject: 'Your audition application has been received'
    )
  end

  def admin_email
    mail(
      to: 'albert_nikolli@icloud.com',
      subject: 'New Audition Application'
    )
  end

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
