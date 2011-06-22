require 'spec_helper'

describe SurveysController do
  
  def mock_person(stubs={})
    @mock_person ||= mock_model(Person, stubs).as_null_object
  end
  
  def mock_survey(stubs={})
    @mock_survey ||= mock_model(Vote,stubs).as_null_object
  end
  
  def mock_issue(stubs={})
    @mock_issue ||= mock_model(Issue, stubs).as_null_object
  end

  def mock_conversation(stubs={})
    @mock_conversation ||= mock_model(Conversation, stubs).as_null_object
  end
  
  before(:each) do
    controller.stub(:current_person).and_return(mock_person)
  end

  describe "GET show" do
    before(:each) do
      Survey.stub(:find).and_return(mock_survey)
      VoteResponsePresenter.stub(:new)
    end
    
    it "should render the show_vote template if it is a 'vote'" do
      get :show, :id => 123
      response.should render_template('surveys/show_vote')
    end
    
  end
  
  
  describe "find_survey" do
    it "should return the survey" do
      Survey.should_receive(:find).twice.and_return(mock_survey)
      get :show, :id => 123
    end
  end
  
  describe "create_response" do
    describe "post" do
      it "should render the show action when successfully saved" do
        Survey.stub(:find).and_return(mock_survey)
        @vote_response_presenter = stub("VoteResponsePresenter")
        VoteResponsePresenter.stub(:new).and_return(@vote_response_presenter)
        @vote_response_presenter.should_receive(:save).and_return(true)
        
        post :create_response, :id => 123, :survey_response_presenter => {}
        response.should render_template(:action => :show)
      end
      it "should redirect to show_ template when there is an error" do
        Survey.stub(:find).and_return(mock_survey)
        @vote_response_presenter = stub("VoteResponsePresenter")
        VoteResponsePresenter.stub(:new).and_return(@vote_response_presenter)
        @vote_response_presenter.should_receive(:save).and_return(false)
        
        post :create_response, :id => 123, :survey_response_presenter => {}
        response.should render_template('show_vote')
      end
    end
  end

end
