require 'spec_helper'

describe "admin/surveys/show.html.erb" do
  before(:each) do
    @survey = assign(:survey, stub_model(Survey,
      :surveyable_id => 1,
      :surveyable_type => "Surveyable Type",
      :title => "Title",
      :description => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    rendered.should match(/1/)
    rendered.should match(/Surveyable Type/)
    rendered.should match(/Title/)
    rendered.should match(/MyText/)
  end
end
