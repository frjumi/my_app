class ThemesController < ApplicationController
  before_action :set_theme, only: %i[show edit update destroy]

  # GET /themes
  def index
    @themes = Theme.includes(:images).order(:name)
  end

  def show
  end

  def new
    @theme = Theme.new
  end

  def edit
  end

  def create
    @theme = Theme.new(theme_params)

    respond_to do |format|
      if @theme.save
        format.html { redirect_to @theme, notice: t('themes.flash.created') }
        format.json { render :show, status: :created, location: @theme }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @theme.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @theme.update(theme_params)
        format.html { redirect_to @theme, notice: t('themes.flash.updated'), status: :see_other }
        format.json { render :show, status: :ok, location: @theme }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @theme.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @theme.destroy!

    respond_to do |format|
      format.html { redirect_to themes_path, notice: t('themes.flash.destroyed'), status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def set_theme
    @theme = Theme.find(params[:id])
  end

  def theme_params
    params.require(:theme).permit(:name, :qty_items)
  end
end
