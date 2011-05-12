class SurveysController < ApplicationController
  before_filter :require_user
  before_filter :find_surveyable
  before_filter :require_survey
  
  def show
    @survey_response_presenter = VoteResponsePresenter.new(:person_id => current_person.id, :survey_id => @survey.id)
    render :template => "surveys/show_#{@survey.class.name.underscore}"
  end
  
  def create_response
    @survey_response_presenter = VoteResponsePresenter.new({:person_id => current_person.id, :survey_id => @survey.id}.merge!(params[:survey_response_presenter]))
    if @survey_response_presenter.save
      redirect_to :action => :show
    else
      render :template => "surveys/show_#{@survey.class.name.underscore}"
    end
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
      flash[:notice] = "#{@survey.class.name.titlecase} Not found"
      redirect_to @surveyable 
      return false
    end
  end
  
end