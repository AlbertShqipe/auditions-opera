class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  def after_sign_in_path_for(resource)
    if resource.admin? # Check if the user is an admin
      audition_applications_path # Redirect to the audition applications index
    else
      root_path # Redirect to the root page or a candidate's dashboard
    end
  end

end
