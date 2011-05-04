require 'spec_helper'
describe '/survey_options/_survey_option_vote.html.erb' do

  before(:each) do
    view.stub(:option_counter).and_return(1)
    view.stub(:option).and_return(stub_model(SurveyOption))
  end
  
  it "should show the survey-option div" do
    render
    rendered.should have_selector('div.survey-option')
  end
  
end
