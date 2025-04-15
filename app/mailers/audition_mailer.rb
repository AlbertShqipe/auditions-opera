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
      bcc: 'candrieux@opera-lyon.com',
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

  def contact_message(name, email, message)
    @name = name
    @message = message
    @email = email

    mail(
      to: "albert_nikolli@icloud.com", # Replace with your admin email
      from: "no-reply@albert-nikolli-certification-2024.fr",
      subject: "#{name} cannot attend the audition",
    )
  end
end
