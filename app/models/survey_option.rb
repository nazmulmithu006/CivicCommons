class SurveyOption < ActiveRecord::Base
  SURVEYABLE_TYPES = ['Issue', 'Conversation']
  attr_accessor :nested
  belongs_to :survey
  has_many :selected_survey_options, :dependent => :destroy
  validates_presence_of :survey_id, :unless => :nested
  validates_uniqueness_of :position, :scope => :survey_id, :allow_blank => true, :allow_nil => true, :unless => :nested
  scope :position_sorted, {:order =>'position ASC, id ASC'}
end