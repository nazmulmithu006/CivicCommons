class SelectedSurveyOption < ActiveRecord::Base
  belongs_to :survey_option
  belongs_to :survey_response
  validates_presence_of :survey_option_id, :survey_response_id
  validates_uniqueness_of :survey_option_id, :scope => [:survey_response_id, :position], :message => 'has already been chosen by you'
end