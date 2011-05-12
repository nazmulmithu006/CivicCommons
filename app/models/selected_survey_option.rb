class SelectedSurveyOption < ActiveRecord::Base
  attr_accessor :bypass_survey_option_id_uniqueness
  belongs_to :survey_option
  belongs_to :survey_response
  validates_presence_of :survey_option_id, :survey_response_id
  validates_uniqueness_of :survey_option_id, :scope => :survey_response_id, :message => 'has already been selected', :unless => :bypass_survey_option_id_uniqueness?
  
  def bypass_survey_option_id_uniqueness?
    @bypass_survey_option_id_uniqueness ||= false
  end
  
end