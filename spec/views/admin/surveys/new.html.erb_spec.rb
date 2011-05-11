require 'spec_helper'

describe "admin/surveys/new.html.erb" do
  before(:each) do
    assign(:survey, stub_model(Survey,
      :surveyable_id => 1,
      :surveyable_type => "MyString",
      :tye => 'classType',
      :title => "MyString",
      :description => "MyText",
      :options => [stub_model(SurveyOption)]
    ).as_new_record)
  end

  it "renders new survey form" do
    render
    rendered.should have_selector("form", :action => admin_surveys_path, :method => "post") do |form|
      form.should have_selector("input#survey_surveyable_id", :name => "survey[surveyable_id]")
      form.should have_selector("select#survey_surveyable_type", :name => "survey[surveyable_type]")
      form.should have_selector("input#survey_title", :name => "survey[title]")
      form.should have_selector("textarea#survey_description", :name => "survey[description]")
      form.should have_selector("input#survey_max_selected_options", :name => "survey[max_selected_options]")
      form.should have_selector("select#survey_type", :name => "survey[type]")
            
      #survey options
      form.should have_selector("input#survey_options_attributes_0_title", :name => "survey[options_attributes][0][title]")
      form.should have_selector("input#survey_options_attributes_0_nested", :name => "survey[options_attributes][0][nested]")
      form.should have_selector("input#survey_options_attributes_0_position", :name => "survey[options_attributes][0][position]")
    end
  end
end
