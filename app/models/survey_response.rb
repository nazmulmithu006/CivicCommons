class SurveyResponse < ActiveRecord::Base
  belongs_to :option, :class_name => 'SurveyOption', :foreign_key => 'survey_option_id'
  belongs_to :person
  validates_presence_of :person_id, :survey_option_id
end