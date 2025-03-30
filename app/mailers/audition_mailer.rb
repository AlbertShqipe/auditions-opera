class AuditionMailer < ApplicationMailer
  def confirmation_email(application)
    @application = application
    mail(
      to: @application.user.email,
      subject: 'Your audition application has been received'
    )
  end

  def admin_email(application)
    @application = application
    mail(
      to: 'albert_nikolli@icloud.com',
      subject: 'New Audition Application'
    )
  end
end
