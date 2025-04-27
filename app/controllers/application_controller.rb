class ApplicationController < ActionController::Base
  before_action :set_locale
  before_action :authenticate_user!

  def after_sign_in_path_for(resource)
      root_path # Redirect to the root page or a candidate's dashboard
    end
  end

  def default_url_options
    { locale: I18n.locale }
  end

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

end
