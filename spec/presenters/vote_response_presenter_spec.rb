require 'spec_helper'

describe VoteResponsePresenter do
  def given_a_person_and_a_survey_and_presenter
    @person = Factory.create(:registered_user)
    @survey = Factory.create(:vote)
    @survey_option1 = Factory.create(:survey_option,:survey_id => @survey.id, :position => 1)
    @presenter = VoteResponsePresenter.new(:person_id => @person.id,:survey_id => @survey.id)
  end
  it "should allow for selected_option_1_id" do
    given_a_person_and_a_survey_and_presenter
    @presenter.selected_option_1_id.should be_nil
  end
  it "should set selected_option_1_id=" do
    given_a_person_and_a_survey_and_presenter
    @presenter.selected_option_1_id = @survey_option1.id
    @presenter.selected_option_1_id.should == @survey_option1.id
  end
  
  it "should have the person" do
    given_a_person_and_a_survey_and_presenter
    @presenter.person.should == @person
  end
  
  it "should have the survey" do
    given_a_person_and_a_survey_and_presenter
    @presenter.survey.should == @survey
  end
  
  it "should have max_selected_options" do
    given_a_person_and_a_survey_and_presenter
    @presenter.max_selected_options.should == 3
  end
  
  it "should return the survey_option object when selected_option_1 is called" do
    given_a_person_and_a_survey_and_presenter
    @presenter.selected_option_1_id = @survey_option1.id
    @presenter.selected_option_1.should == @survey_option1
  end
  
  context "saving" do
    def given_a_vote_presenter
      @person = Factory.create(:registered_user)
      @survey = Factory.create(:vote)
      @survey_option1 = Factory.create(:survey_option,:survey_id => @survey.id, :position => 1)
      @presenter = VoteResponsePresenter.new(:person_id => @person.id,
        :survey_id => @survey.id, 
        :selected_option_1_id => 11, 
        :selected_option_2_id => 22)
    end
    
    def given_a_bare_vote_presenter
      @person = Factory.create(:registered_user)
      @survey = Factory.create(:vote)
      @survey_option1 = Factory.create(:survey_option,:survey_id => @survey.id, :position => 1)
      @presenter = VoteResponsePresenter.new(:person_id => @person.id,
        :survey_id => @survey.id)
    end
    
    it "should correctly save the survey_response" do
      given_a_vote_presenter
      @presenter.save
      @presenter.should be_persisted
      @presenter.survey_response.should be_persisted
    end
    
    it "should correctly save the selected_survey_options when associating using the ids" do
      given_a_vote_presenter
      @presenter.selected_option_1_id.should == 11
      @presenter.selected_option_2_id.should == 22
      @presenter.save
      @presenter.selected_survey_option_1.should be_persisted
      @presenter.selected_survey_option_2.should be_persisted
    end
    
    it "should correctly save the selected_survey_options when associating using the object" do
      given_a_bare_vote_presenter
      @presenter.selected_option_1 = @survey_option1
      @presenter.save
      @presenter.selected_survey_option_1.should be_persisted
    end
    
    it "should not define more than the maximum selected_survey_options" do
      given_a_vote_presenter
      defined?(@presenter.selected_option_99).should be_false
    end
    
    it "should destroy the selected_survey_option record if selected_option is blank" do
      given_a_vote_presenter
      @presenter.save
      @presenter.selected_option_1_id.should == 11
      
      @presenter = VoteResponsePresenter.new(:person_id => @person.id,
        :survey_id => @survey.id, :selected_option_1_id => nil)  
      @presenter.save
      @presenter.selected_option_1_id.should be_blank
      @presenter.selected_survey_option_1.should be_destroyed
    end
    
    context "available options" do
      it "should show the available survey options what is remaining" do
        given_a_person_and_a_survey_and_presenter
        @presenter.available_options.should == [@survey_option1]
      end      
    end
  end
end