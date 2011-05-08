require 'spec_helper'

describe SurveyResponse do
  context "Associations" do
    it "should has many selected_survey_options" do
      SurveyResponse.reflect_on_association(:selected_survey_options).macro.should == :has_many
    end
    
    it "should belong to person" do
      SurveyResponse.reflect_on_association(:person).macro.should == :belongs_to
    end
    
    it "should belong_to survey" do
      SurveyResponse.reflect_on_association(:survey).macro.should == :belongs_to
    end
  end

  context "Validations" do
    before(:each) do
      @survey_response = SurveyResponse.create
    end
    it "should validate presence of person_id" do
      @survey_response.errors[:person_id].should == ["can't be blank"]
    end
  end

end