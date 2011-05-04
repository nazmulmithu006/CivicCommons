require 'spec_helper'
describe '/surveys/show_vote.html.erb' do
    
  def content_for(name) 
    view.instance_variable_get(:@_content_for)[name] 
  end
  
  before(:each) do
    @survey = stub_model(Survey, :type => 'vote')
    @surveyable = stub_model(Issue)
    @survey_options = [stub_model(SurveyOption)]
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
  
end
