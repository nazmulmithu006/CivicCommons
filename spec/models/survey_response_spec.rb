require 'spec_helper'

describe SurveyResponse do
  context "Associations" do
    it "should belong to option" do
      SurveyResponse.reflect_on_association(:option).macro.should == :belongs_to
    end
    
    it "should belong_to option with the correct options" do
      SurveyResponse.reflect_on_association(:option).options.should == {:class_name=>"SurveyOption", :foreign_key=>"survey_option_id"}
    end
    
    it "should belong to person" do
      SurveyResponse.reflect_on_association(:person).macro.should == :belongs_to
    end
    
  end

  context "Validations" do
    before(:each) do
      @survey_response = SurveyResponse.create
    end
    it "should validate presence of person_id" do
      @survey_response.errors[:person_id].should == ["can't be blank"]
    end
    
    it "should validate presence of survey_option_id" do
      @survey_response.errors[:survey_option_id].should == ["can't be blank"]
    end
    
  end

end