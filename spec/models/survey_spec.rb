require 'spec_helper'

describe Survey do
  context "Associations" do
    context "has_many :options" do
      it "should have many options" do
        Survey.reflect_on_association(:options).macro.should == :has_many
      end
      
      it "should have many options with the correct options" do
        Survey.reflect_on_association(:options).options.should == {:class_name=>"SurveyOption", :foreign_key=>"survey_id", :dependent=>:destroy, :extend=>[]}
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
end
