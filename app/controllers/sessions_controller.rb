class SessionsController < ApplicationController
  def new
    # форма входа
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      sign_in user
      redirect_to work_path
    else
      flash.now[:alert] = I18n.t('sessions.flash.invalid_credentials')
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end
end
