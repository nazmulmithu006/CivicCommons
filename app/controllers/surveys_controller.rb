class SurveysController < ApplicationController
  before_filter :require_user
  before_filter :find_survey
  
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

  def find_survey
      @survey = Survey.find(params[:id])
  end
  
end