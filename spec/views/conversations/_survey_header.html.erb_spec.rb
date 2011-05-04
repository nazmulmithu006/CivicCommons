require 'spec_helper'
describe '/conversations/_survey_header.html.erb' do

  before(:each) do
    @surveyable = stub_model(Conversation,   
      :title => 'title here',
      :summary => 'Summary here'
    )
  end
  
  it "should show the Conversation title" do
    render
    rendered.should contain 'title here'
  end
  
  it "should show the Conversation summary" do
    render
    rendered.should contain 'Summary here'
  end

end
