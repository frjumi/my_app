class ValuesController < ApplicationController
  before_action :signed_in_user
  before_action :set_value, only: %i[show edit update destroy]
  before_action :authorize_value_owner!, only: %i[show edit update destroy]

  # GET /values — только оценки текущего пользователя
  def index
    @values = current_user.values.includes(image: :theme).order(created_at: :desc)
    @unrated_images = unrated_images_for_current_user
  end

  def show
  end

  def new
    @value = Value.new
    @value.image_id = params[:image_id] if params[:image_id].present?
    @unrated_images = unrated_images_for_current_user
  end

  def edit
  end

  def create
    @value = current_user.values.build(value_params)

    respond_to do |format|
      if @value.save
        format.html { redirect_to values_path, notice: t('values.flash.created') }
        format.json { render :show, status: :created, location: @value }
      else
        @unrated_images = unrated_images_for_current_user
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @value.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @value.update(value_params)
        format.html { redirect_to values_path, notice: t('values.flash.updated'), status: :see_other }
        format.json { render :show, status: :ok, location: @value }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @value.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @value.destroy!

    respond_to do |format|
      format.html { redirect_to values_path, notice: t('values.flash.destroyed'), status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def set_value
    @value = Value.find(params[:id])
  end

  def value_params
    params.require(:value).permit(:image_id, :value)
  end

  def authorize_value_owner!
    return if @value.user_id == current_user.id

    redirect_to values_path, alert: t('values.flash.access_denied')
  end

  def unrated_images_for_current_user
    rated_ids = current_user.values.select(:image_id)
    Image.where.not(id: rated_ids).includes(:theme).order(:name)
  end
end
