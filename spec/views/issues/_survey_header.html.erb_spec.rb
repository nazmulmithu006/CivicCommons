require 'spec_helper'
describe '/issues/_survey_header.html.erb' do

  before(:each) do
    @surveyable = stub_model(Issue,   
      :name => 'Name here',
      :summary => 'Summary here'
    )
    stub_template('subscriptions/_subscription.html.erb' => 'rendering subscription')
  end
  
  it "should show the Issue name" do
    render
    rendered.should contain 'Name here'
  end
  
  it "should show the follow Issue button" do
    render
    rendered.should render_template 'subscriptions/_subscription'
  end

end
