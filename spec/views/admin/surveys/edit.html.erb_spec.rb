require 'spec_helper'

describe "admin/surveys/edit.html.erb" do
  before(:each) do
    @survey = assign(:survey, stub_model(Survey,
      :surveyable_id => 1,
      :surveyable_type => "MyString",
      :title => "MyString",
      :description => "MyText",
      :options => [stub_model(SurveyOption)]
    ))
  end

  it "renders the edit survey form" do
    render
    rendered.should have_selector("form", :action => admin_survey_path(@survey), :method => "post") do |form|
      form.should have_selector("input#survey_surveyable_id", :name => "survey[surveyable_id]")
      form.should have_selector("select#survey_surveyable_type", :name => "survey[surveyable_type]")
      form.should have_selector("input#survey_title", :name => "survey[title]")
      form.should have_selector("textarea#survey_description", :name => "survey[description]")
      form.should have_selector("input#survey_max_selected_options", :name => "survey[max_selected_options]")
      
      #survey options
      form.should have_selector("input#survey_options_attributes_0_title", :name => "survey[options_attributes][0][title]")
      form.should have_selector("input#survey_options_attributes_0_nested", :name => "survey[options_attributes][0][nested]")
      form.should have_selector("input#survey_options_attributes_0_position", :name => "survey[options_attributes][0][position]")
    end
  end
end
