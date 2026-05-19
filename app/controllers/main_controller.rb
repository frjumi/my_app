class MainController < ApplicationController
  def index
    @themes_count = Theme.count
    @images_count = Image.count
  end

  def help
  end

  def contacts
  end

  def about
  end
end
