require 'spec_helper'

describe "admin/surveys/new.html.erb" do
  before(:each) do
    assign(:survey, stub_model(Survey,
      :surveyable_id => 1,
      :surveyable_type => "MyString",
      :title => "MyString",
      :description => "MyText"
    ).as_new_record)
  end

  it "renders new survey form" do
    render
    rendered.should have_selector("form", :action => admin_surveys_path, :method => "post") do |form|
      form.should have_selector("input#survey_surveyable_id", :name => "survey[surveyable_id]")
      form.should have_selector("input#survey_surveyable_type", :name => "survey[surveyable_type]")
      form.should have_selector("input#survey_title", :name => "survey[title]")
      form.should have_selector("textarea#survey_description", :name => "survey[description]")
    end
  end
end
