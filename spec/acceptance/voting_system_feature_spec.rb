require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')
WebMock.allow_net_connect!
Capybara.register_driver :selenium do |app|
  Capybara::Driver::Selenium.new(app, :browser => :chrome)
end

Capybara.default_wait_time = 20


feature "Voting system", %q{
  In order to voice my opinion
  As a current user
  I want to vote on something
} do
  
  let (:vote_page)               { VotePage.new(page) }
  let (:login_page)                 { LoginPage.new(page) }
  
  def given_a_registered_user
    @person = Factory.create(:registered_user, :email => 'johnd@example.com', :declined_fb_auth => true)
  end
  
  def given_an_issue
    @issue = Factory.create(:issue)
    @survey = Factory.create(:vote)
    @survey_option1 = Factory.create(:survey_option,:survey_id => @survey.id, :position => 1)
    @survey_option2 = Factory.create(:survey_option,:survey_id => @survey.id, :position => 2)
    @survey_option3 = Factory.create(:survey_option,:survey_id => @survey.id, :position => 3)
  end
  
  def given_an_independent_vote
    @vote = Factory.create(:vote,:surveyable_type => nil, :surveyable_id => nil)
    @survey_option1 = Factory.create(:survey_option,:survey_id => @vote.id, :position => 1)
    @survey_option2 = Factory.create(:survey_option,:survey_id => @vote.id, :position => 2)
    @survey_option3 = Factory.create(:survey_option,:survey_id => @vote.id, :position => 3)
  end

  scenario "Voting and submitting", :js => true do
    # Given I am a registered user at The Civic Commons
    given_a_registered_user
    
    # Given an issue
    given_an_issue
    
    # And I login
    login_page.sign_in(@person)
    
    # And I visit the vote page on the issue
    vote_page.visit_vote_on_an_issue(@issue)
    
    # I should see 3 options available to be selected
    vote_page.should have_selector(VotePage::OPTIONS_LOCATOR, :count => 3)
    
    # When I drag and drop to selection
    vote_page.select_one_option
    
    # Then I should see 2 options left to be selected
    vote_page.should have_selector(VotePage::OPTIONS_LOCATOR, :count => 2)
    
    # And I should see 1 options already selected
    vote_page.should have_selector(VotePage::SELECTED_OPTIONS_LOCATOR, :count => 1)
    
    # When I click submit
    vote_page.click_submit
    
    # And I should see 2 options left to be selected
    vote_page.should have_selector(VotePage::OPTIONS_LOCATOR, :count => 2)
    
    # And I should see 1 options already selected
    vote_page.should have_selector(VotePage::SELECTED_OPTIONS_LOCATOR, :count => 1)
    
  end
  
  scenario "independent votes", :js => true do
    # Given I am a registered user at The Civic Commons
    given_a_registered_user
    
    # Given an independent vote
    given_an_independent_vote
    
    # And I login
    login_page.sign_in(@person)
    
    # And I visit the vote page on the issue
    vote_page.visit_an_independent_vote(@vote)
    
    # I should see 3 options available to be selected
    vote_page.should have_selector(VotePage::OPTIONS_LOCATOR, :count => 3)
    
    # When I drag and drop to selection
    vote_page.select_one_option
    
    # Then I should see 2 options left to be selected
    vote_page.should have_selector(VotePage::OPTIONS_LOCATOR, :count => 2)
    
    # And I should see 1 options already selected
    vote_page.should have_selector(VotePage::SELECTED_OPTIONS_LOCATOR, :count => 1)
    
    # When I click submit
    vote_page.click_submit
    
    # And I should see 2 options left to be selected
    vote_page.should have_selector(VotePage::OPTIONS_LOCATOR, :count => 2)
    
    # And I should see 1 options already selected
    vote_page.should have_selector(VotePage::SELECTED_OPTIONS_LOCATOR, :count => 1)
    
  end
end
