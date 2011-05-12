require 'spec_helper'

describe SelectedSurveyOption do
  context "Associations" do
    it "should belongs_to survey_response" do
      SelectedSurveyOption.reflect_on_association(:survey_response).macro.should == :belongs_to
    end
    
    it "shold belongs_to survey_option" do
      SelectedSurveyOption.reflect_on_association(:survey_option).macro.should == :belongs_to
    end
  end
  
  context "Validations" do
    context "validates_presence_of" do
      before(:each) do
        @selected_survey_option = SelectedSurveyOption.create
      end
      it "should validate presence of survey_response_id" do
        @selected_survey_option.errors[:survey_response_id].should == ["can't be blank"]
      end
      it "should validate presence of survey_option_id" do
        @selected_survey_option.errors[:survey_option_id].should == ["can't be blank"]
      end
    end
    context "validates_uniqueness_of" do
      it "should throw validation error if a selected survey option is created on the same position, survey option, and survey response" do
        @selected_survey_option1 = SelectedSurveyOption.create(:position => 123, :survey_option_id => 123, :survey_response_id => 123)
        @selected_survey_option2 = SelectedSurveyOption.create(:position => 123, :survey_option_id => 123, :survey_response_id => 123)
        @selected_survey_option2.errors[:survey_option_id].should == ["has already been selected"]
      end
    end
  end
  
end