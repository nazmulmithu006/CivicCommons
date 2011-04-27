class CreateSurveys < ActiveRecord::Migration
  def self.up
    create_table :surveys, :force => true do |t|
      t.integer :surveyable_id
      t.string :surveyable_type
      t.string :title
      t.text :description
      t.string :type
      t.timestamps
    end
    
    create_table :survey_options, :force => true do |t|
      t.text :title
      t.integer :survey_id
      t.timestamps
    end
    
    create_table :survey_responses, :force => true do |t|
      t.integer :survey_option_id
      t.integer :person_id
      t.integer :position
      t.timestamps
    end
  end

  def self.down
    drop_table :survey_responses
    drop_table :survey_options
    drop_table :surveys
  end
end