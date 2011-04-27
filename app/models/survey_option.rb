class SurveyOption < ActiveRecord::Base
  belongs_to :survey
  has_many :responses, :class_name => 'SurveyResponse', :foreign_key => 'survey_option_id', :dependent => :destroy
  validates_presence_of :survey_id
end