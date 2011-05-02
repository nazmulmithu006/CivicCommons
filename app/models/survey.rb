class Survey < ActiveRecord::Base
  belongs_to :surveyable, :polymorphic => true
  has_many :options, :class_name => 'SurveyOption', :foreign_key => 'survey_id', :dependent => :destroy
  validates_presence_of :surveyable_id, :surveyable_type
  accepts_nested_attributes_for :options, :reject_if => :all_blank, :allow_destroy => true
end