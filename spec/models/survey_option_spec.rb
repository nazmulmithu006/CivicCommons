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
    before(:each) do
      @survey_option = SurveyOption.create
    end
    it "should validate presence of survey" do
      @survey_option.errors[:survey_id].should == ["can't be blank"]
    end
  end

end
