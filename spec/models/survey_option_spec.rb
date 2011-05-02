require 'spec_helper'

describe SurveyOption do
  context "Associations" do
    it "should belong to poll" do
      SurveyOption.reflect_on_association(:survey).macro.should == :belongs_to
    end
    
    it "should has many responses" do
      SurveyOption.reflect_on_association(:responses).macro.should == :has_many
    end
    
    it "should has_many responses with the correct options" do
      SurveyOption.reflect_on_association(:responses).options.should == {:class_name=>"SurveyResponse", :foreign_key=>"survey_option_id", :extend=>[], :dependent => :destroy}
    end
    
  end

  context "Validations" do
    def given_an_invalid_survey_option
      @survey_option = SurveyOption.create
    end
    
    it "should validate presence of survey" do
      given_an_invalid_survey_option
      @survey_option.errors[:survey_id].should == ["can't be blank"]
    end
    
    it "should validate uniqueness of survey" do
      @survey_option1 = Factory.create(:survey_option, :position => 1, :survey_id => 1)
      @survey_option2 = Factory.build(:survey_option, :position => 1, :survey_id => 1)
      @survey_option2.valid?
      @survey_option2.errors[:position].should == ["has already been taken"]
    end
  end
  
  context "named scope" do
    def given_a_few_surveys 
      @survey_option2 = Factory.create(:survey_option, :position => 2)
      @survey_option1 = Factory.create(:survey_option, :position => 1)
    end

    it "should " do
      given_a_few_surveys
      SurveyOption.position_sorted.all.should == [@survey_option1, @survey_option2]
    end
    
  end

end
