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
      @surveyable = mock_issue(:survey => mock_survey())
      Issue.stub(:find).and_return(@surveyable)
      # @option1 = mock_model(SurveyOption)
      # @option2 = mock_model(SurveyOption)
      VoteResponsePresenter.stub(:new)
    end
    
    it "should render the show_vote template if it is a 'vote'" do
      get :show, :issue_id => 123
      response.should render_template('surveys/show_vote')
    end
    
  end
  
  describe "require_survey" do
    before(:each) do
      Issue.stub(:find).and_return(mock_issue(:survey => nil))
    end
    
    it "should redirect to the surveyable model if survey record is not found" do
      get :show, :issue_id => 123
      response.should redirect_to @mock_issue
    end
  end
  
  describe "find_surveyable" do
    it "should return the Issue model if issue_id is passed" do
      @surveyable = mock_issue(:survey => mock_survey())
      Issue.should_receive(:find).and_return(@surveyable)
      VoteResponsePresenter.stub(:new)
      get :show, :issue_id => 123
    end
    it "should return the Conversation model if conversation_id is passed" do
      @surveyable = mock_conversation(:survey => mock_survey())
      Conversation.should_receive(:find).and_return(@surveyable)
      VoteResponsePresenter.stub(:new)
      get :show, :conversation_id => 123
    end
  end
  
  describe "create_response" do
    describe "post" do
      it "should render the show action when successfully saved" do
        @surveyable = mock_issue(:survey => mock_survey())
        Issue.stub(:find).and_return(@surveyable)
        @surveyable = mock_issue(:survey => mock_survey())
        @vote_response_presenter = stub("VoteResponsePresenter")
        VoteResponsePresenter.stub(:new).and_return(@vote_response_presenter)
        @vote_response_presenter.should_receive(:save).and_return(true)
        
        post :create_response, :issue_id => 123, :survey_response_presenter => {}
        response.should render_template(:action => :show)
      end
      it "should redirect to show_ template when there is an error" do
        @surveyable = mock_issue(:survey => mock_survey())
        Issue.stub(:find).and_return(@surveyable)
        @surveyable = mock_issue(:survey => mock_survey())
        @vote_response_presenter = stub("VoteResponsePresenter")
        VoteResponsePresenter.stub(:new).and_return(@vote_response_presenter)
        @vote_response_presenter.should_receive(:save).and_return(false)
        
        post :create_response, :issue_id => 123, :survey_response_presenter => {}
        response.should render_template('show_vote')
      end
    end
  end

end
