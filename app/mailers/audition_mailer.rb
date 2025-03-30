class AuditionMailer < ApplicationMailer
  def confirmation_email(application)
    @application = audition_application
    mail(
      to: @application.user.email,
      subject: 'Your audition application has been received'
    )
  end
end
