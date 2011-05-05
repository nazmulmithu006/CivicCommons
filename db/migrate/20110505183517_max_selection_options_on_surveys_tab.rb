class MaxSelectionOptionsOnSurveysTab < ActiveRecord::Migration
  def self.up
    add_column :surveys, :max_selected_options, :integer, :default => 0
  end

  def self.down
    remove_column :surveys, :max_selected_options
  end
end