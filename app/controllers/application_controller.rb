class ApplicationController < ActionController::Base
  include SessionsHelper
  private

  def signed_in_user
    unless signed_in?
      flash[:notice] = "Please sign in."
      redirect_to signin_url
    end
  end
end