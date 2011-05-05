class SurveysController < ApplicationController
  before_filter :require_user
  before_filter :find_surveyable
  before_filter :require_survey
  
  def show
    @max_vote = @survey.max_selected_options
    @survey_options = @survey.options.position_sorted
    render :template => "surveys/show_#{params[:type]}"
  end
  
protected  

  def find_surveyable
    if !params[:issue_id].blank?
      @surveyable = Issue.find(params[:issue_id])
    elsif !params[:conversation_id].blank?
      @surveyable = Conversation.find(params[:conversation_id])
    end
    @survey = @surveyable.survey
  end
  
  def require_survey
    if @survey.blank?
      flash[:notice] = "#{params[:type].titlecase} Not found"
      redirect_to @surveyable 
      return false
    end
  end
  
end