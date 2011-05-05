class ModifySurveyTables < ActiveRecord::Migration
  def self.up
    remove_column :survey_responses, :survey_option_id
    remove_column :survey_responses, :position
    add_column :survey_responses, :survey_id, :integer
    
    create_table :selected_survey_options, :force => true do |t|
      t.integer :survey_option_id
      t.integer :survey_response_id
      t.integer :position
      t.timestamps
    end
  end

  def self.down
    drop_table :selected_survey_options
    
    remove_column :survey_responses, :survey_id
    add_column :survey_responses, :position, :integer
    add_column :survey_responses, :survey_option_id, :integer
  end
end