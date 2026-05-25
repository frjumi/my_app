class ApplicationController < ActionController::Base
  include SessionsHelper

  before_action :set_locale

  private

  def set_locale
    I18n.locale = extract_locale || I18n.default_locale
  end

  def extract_locale
    locale = params[:locale]&.to_sym
    return locale if locale.present? && I18n.available_locales.include?(locale)

    nil
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