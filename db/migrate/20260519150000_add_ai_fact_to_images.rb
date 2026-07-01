# frozen_string_literal: true

class AddAiFactToImages < ActiveRecord::Migration[7.1]
  def change
    add_column :images, :ai_fact, :text
  end
end
