class Survey < ActiveRecord::Base
  belongs_to :surveyable, :polymorphic => true
  has_many :options, :class_name => 'SurveyOption', :foreign_key => 'survey_id', :dependent => :destroy
  validates_presence_of :surveyable_id, :surveyable_type, :max_selected_options
  validates_numericality_of :max_selected_options, :only_integer => true
  accepts_nested_attributes_for :options, :reject_if => :all_blank, :allow_destroy => true
end