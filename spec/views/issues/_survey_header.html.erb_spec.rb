require 'spec_helper'
describe '/issues/_survey_header.html.erb' do

  before(:each) do
    @surveyable = stub_model(Issue,   
      :name => 'Name here',
      :summary => 'Summary here'
    )
  end
  
  it "should show the Issue name" do
    render
    rendered.should contain 'Name here'
  end
  
  it "should show the Issue summary" do
    render
    rendered.should contain 'Summary here'
  end

end
