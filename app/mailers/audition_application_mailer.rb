class AuditionApplicationMailer < ApplicationMailer
  def status_update(application)
    @application = application
    mail(to: @application.user.email, subject: "Your Audition Application Status Has Changed")
  end
end
