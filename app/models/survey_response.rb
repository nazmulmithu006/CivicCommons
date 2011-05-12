class SurveyResponse < ActiveRecord::Base
  has_many :selected_survey_options
  belongs_to :person
  belongs_to :survey
  validates_presence_of :person_id
end