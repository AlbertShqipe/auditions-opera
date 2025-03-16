class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
  end

  def index
    # Your code here
  end

  def show
    # Your code here
  end

  private

  def check_admin
    redirect_to root_path, alert: "Access denied!" unless current_user.admin?
  end
end
