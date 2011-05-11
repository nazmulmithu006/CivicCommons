require 'spec_helper'

describe "admin/surveys/show.html.erb" do
  before(:each) do
    @survey = assign(:survey, stub_model(Survey,
      :surveyable_id => 1,
      :surveyable_type => "Surveyable Type",
      :type => 'classType',
      :title => "Title",
      :description => "MyText",
      :max_selected_options => 5
    ))
    @survey.stub_chain(:options, :position_sorted).and_return([stub_model(SurveyOption, :title => 'myOptionTitle', :description => 'myOptionDescription',:position => 123 )])
  end

  it "renders attributes in <p>" do
    render
    rendered.should match(/1/)
    rendered.should match(/Surveyable Type/)
    rendered.should match(/Title/)
    rendered.should match(/MyText/)
    rendered.should match(/classType/)
    rendered.should match(/myOptionTitle/)
    rendered.should match(/myOptionDescription/)
    rendered.should match(/123/)
    rendered.should match(/5/)
  end
end
