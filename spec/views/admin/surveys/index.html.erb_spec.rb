require 'spec_helper'

describe "admin/surveys/index.html.erb" do
  before(:each) do
    assign(:surveys, [
      stub_model(Survey,
        :surveyable_id => 1,
        :surveyable_type => "Surveyable Type",
        :title => "Title",
        :description => "MyText"
      ),
      stub_model(Survey,
        :surveyable_id => 1,
        :surveyable_type => "Surveyable Type",
        :title => "Title",
        :description => "MyText"
      )
    ])
  end

  it "renders a list of admin_surveys" do
    render
    rendered.should have_selector( "tr>td", :content => 1.to_s, :count => 2 )
    rendered.should have_selector( "tr>td", :content => "Surveyable Type".to_s, :count => 2 )
    rendered.should have_selector( "tr>td", :content => "Title".to_s, :count => 2 )
    rendered.should have_selector( "tr>td", :content => "MyText".to_s, :count => 2 )
  end
end
