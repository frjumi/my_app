class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :signed_in_user, only: [:index, :profile, :update_avatar, :remove_avatar, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update, :destroy]

  # GET /users
  def index
    @users = User.all
  end

  # GET /users/1
  def show
  end

  # GET /profile — «Моя страница» текущего пользователя
  def profile
    load_profile_data
  end

  # PATCH /profile/avatar — загрузка или замена аватара
  def update_avatar
    @user = current_user
    if @user.update(avatar_params)
      redirect_to profile_path, notice: t('users.profile.avatar_updated')
    else
      load_profile_data
      flash.now[:alert] = @user.errors.full_messages.join(', ')
      render :profile, status: :unprocessable_entity
    end
  end

  # DELETE /profile/avatar — удаление аватара (снова Gravatar по email)
  def remove_avatar
    current_user.avatar.purge if current_user.avatar.attached?
    redirect_to profile_path, notice: t('users.profile.avatar_removed')
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user   # автоматический вход после регистрации
      redirect_to work_path, notice: 'User was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
    redirect_to users_url, notice: 'User was successfully destroyed.'
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def avatar_params
    params.require(:user).permit(:avatar)
  end

  def load_profile_data
    @user = current_user
    @values_count = @user.values.count
    @aligned_values = @user.aligned_values
  end

  # Проверка, что текущий пользователь имеет право редактировать/удалять этот аккаунт
  def correct_user
    redirect_to root_url, alert: 'Access denied.' unless current_user == @user
  end

  # Доступ к списку пользователей и редактированию только авторизованным
  def signed_in_user
    unless signed_in?
      redirect_to signin_url, notice: 'Please sign in.'
    end
  end
end