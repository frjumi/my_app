class ImagesController < ApplicationController
  before_action :set_image, only: %i[show edit update destroy]

  # GET /images
  def index
    @images = Image.includes(:theme, :values).order(:name)
    @user_ratings = load_user_ratings(@images)
  end

  def show
  end

  def new
    @image = Image.new
  end

  def edit
  end

  def create
    @image = Image.new(image_params)

    respond_to do |format|
      if @image.save
        format.html { redirect_to @image, notice: t('images.flash.created') }
        format.json { render :show, status: :created, location: @image }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @image.update(image_params)
        format.html { redirect_to @image, notice: t('images.flash.updated'), status: :see_other }
        format.json { render :show, status: :ok, location: @image }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @image.destroy!

    respond_to do |format|
      format.html { redirect_to images_path, notice: t('images.flash.destroyed'), status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def set_image
    @image = Image.find(params[:id])
  end

  def image_params
    params.require(:image).permit(:name, :file, :ave_value, :theme_id)
  end

  def load_user_ratings(images)
    return {} unless signed_in?

    Value.where(user_id: current_user.id, image_id: images.map(&:id)).index_by(&:image_id)
  end
end
