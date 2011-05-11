require 'spec_helper'

describe Survey do
  context "Associations" do
    context "has_many :options" do
      it "should have many options" do
        Survey.reflect_on_association(:options).macro.should == :has_many
      end
      
      it "should have the class name as 'SurveyOption" do
        Survey.reflect_on_association(:options).options[:class_name].should == "SurveyOption"
      end
      
      it "should have foreign_key as 'survey_id" do
        Survey.reflect_on_association(:options).options[:foreign_key].should == 'survey_id'        
      end
      
      it "should destroy dependent when it is destroyed" do
        Survey.reflect_on_association(:options).options[:dependent].should == :destroy
      end
    end
    
    context "belongs_to :surveyable" do
      it "should really belongs to surveyable" do
        Survey.reflect_on_association(:surveyable).macro.should == :belongs_to
      end
      
      it "should be polymorphic " do
        Survey.reflect_on_association(:surveyable).options.should == {:polymorphic=>true, :foreign_type=>"surveyable_type"}
      end
    end
    
    context "accepts_nested_attributes_for :options" do
      it "should correctly create nested models" do
        @survey = Factory.build(:survey)
        @survey.options_attributes = [{:title => 'option title here', :description => 'option description here', :nested => true}]
        @survey.save
        @survey.should be_valid
        SurveyOption.count.should == 1
      end
      
    end
    
    it "should have many survey_responses" do
      Person.reflect_on_association(:survey_responses).macro == :has_many
    end
    
  end

  context "Validations" do
    before(:each) do
      @survey = Survey.create
    end
    it "should validate presence of surveyable" do
      @survey.errors[:surveyable_id].should == ["can't be blank"]
      @survey.errors[:surveyable_type].should == ["can't be blank"]
    end
  end
  
  context "Single Table Inheritance" do
    it "can be a Vote" do
      Vote.superclass.should == Survey
    end
    it "can be a Poll" do
      Poll.superclass.should == Survey
    end
  end
end
