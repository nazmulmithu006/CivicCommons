class DescriptionOnSurveyOptionsTab < ActiveRecord::Migration
  def self.up
    add_column :survey_options, :description, :text
    add_column :survey_options, :position, :integer
  end

  def self.down
    remove_column :survey_options, :position
    remove_column :survey_options, :description
  end
end