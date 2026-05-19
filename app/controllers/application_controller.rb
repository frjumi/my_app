class ApplicationController < ActionController::Base
  include SessionsHelper

  before_action :set_locale

  private

  def set_locale
    I18n.locale = extract_locale_from_params || I18n.default_locale
    Rails.application.routes.default_url_options[:locale] = I18n.locale
  end

  def extract_locale_from_params
    if params[:locale] && I18n.available_locales.include?(params[:locale].to_sym)
      params[:locale]
    end
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def signed_in_user
    unless signed_in?
      flash[:notice] = "Please sign in."
      redirect_to signin_url
    end
  end
end