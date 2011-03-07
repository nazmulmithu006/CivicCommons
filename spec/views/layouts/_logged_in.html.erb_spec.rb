require 'view_spec_helper'

describe "layouts/_logged_in.html.erb" do
  before(:each) do
    # @person = stub_model(Person,
    #   :facebook_authenticated? => true
    # )
  end

  it "renders the facebook link when a person don't have a facebook account" do
    Webrat.class.should == ''
    render
    rendered.should have_content('a.hello')
    # rendered.should contain('hello')
    # response.should have_text "hello"
  end
end
