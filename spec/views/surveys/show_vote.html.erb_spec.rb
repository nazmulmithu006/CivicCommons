require 'spec_helper'
describe '/surveys/show_vote.html.erb' do
    
  def content_for(name) 
    view.instance_variable_get(:@_content_for)[name] 
  end
  
  before(:each) do
    @surveyable = stub_model(Issue)
    @survey = stub_model(Vote, :surveyable => @surveyable)
    @survey_options = [stub_model(SurveyOption)]
    @person = stub_model(Person)
    @survey_response_presenter = stub("VoteResponsePresenter", 
      :available_options => @survey_options, 
      :survey => @survey, 
      :max_selected_options => 3).as_null_object
      
    view.stub(:current_person).and_return(@person)
  end
  
  it "should render the correct header based on what model is @surveyable" do
    render
    content_for(:main_body).should render_template("issues/_survey_header")
  end
  
  it "should render the survey options for 'vote'" do
    render
    content_for(:main_body).should render_template('survey_options/_survey_option_vote')
  end
  
  it "should display the selected-survey-options div" do
    render
    content_for(:main_body).should have_selector('div.selected-survey-options')
  end
  it "should display the survey-options div" do
    render
    content_for(:main_body).should have_selector('div.survey-options')
  end
  
  it "should display the vote box multiple times" do
    render
    content_for(:main_body).should have_selector('.selected-survey-options .sortable-wrapper',:count => 3)
  end
  
end
