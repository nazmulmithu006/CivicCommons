Feature: 8457517 link local account with facebook
  In order use CivicCommons
  As an existing user with a local account
  I want to authenticate through Facebook
  So that I only have to remember one login and password
    
  # Scenario: User can see Facebook credentials boxes
  #   Given I am not logged in
  #   And I am on the home page
  #   Then I should see a "Login with Facebook" button
  #   When I click the "Login with Facebook" button
  #   Then I should be on the "Login with Facebook" page
  #   And I should see Facebook credentials boxes
  #   
  # Scenario: User filled in correct Facebook credentials
  #   Given I am not logged in
  #   And I am on the "Login with Facebook" page
  #   When I fill in the Facebook credentials boxes with valid Facebook credentials
  #   And I click the "Login" button
  #   Then I should be logged in
  # 
  # Scenario: User Filled in invalid Facebook credentials
  #   Given I am not logged in
  #   And I am on the "Login with Facebook" page
  #   When I fill in the Facebook credentials boxes with invalid Facebook credentials
  #   And I click the "Login" button
  #   Then I should see an error message
  #   And I should not be logged in
  # 
  # Scenario: User logs in locally using CivicCommons credentials
  #   Given I am not logged in
  #   And I am on the home page
  #   Then I should see a "Login Locally" button
  #   When I click the "Login Locally" button
  #   Then I should be on the local login page
  # 
  Scenario: User sees "Link my account with Facebook" button when logged in
    Given I have a confirmed local user account
    And I am logged in
    When I am on the home page
    Then I should see "Link my account with Facebook"  

  Scenario: User can successfully Link their account with Facebook
    Given I have a confirmed local user account
    And I am logged in
    When I am on the home page
    And I follow "Link my account with Facebook"
    And Facebook reply
    Then I should see "http://www.facebook.com/profile.php?id=100000107280617"
    

  # 
  # Scenario: User sees relevant facebook instructions, when logged in.
  #   Given I am logged in
  #   And I am on the home page
  #   When I select the "link my account with Facebook" link
  #   Then I should be on the Facebook linking page
  #   And I should see the relevant instructions
  #   And I should see Facebook credentials boxes

  # Scenario: On facebook linking page
  # Given I am on the Facebook linking page
  # When I fill in the Facebook credentials boxes with valid Facebook credentials
  # And I click the Login button
  # Then I should see the Facebook linking process happen
  # And I should receive positive confirmation of the linking
  # And my local account should be linked with my Facebook account
  # 
  # Scenario: failing linked Facebook credentials
  # Given I am on the Facebook linking page
  # When I fill in the Facebook credentials boxes with invalid Facebook credentials
  # And I click the Login button
  # Then I should see the Facebook linking process happen
  # And I should see an error message
  # And my local account should not be linked with a Facebook account
  # 
  # Scenario: Not logged in, should not be logged in
  # Given I have a local account linked with Facebook
  # And I am not logged in to Facebook
  # When I visit the home page
  # I should see the normal login box
  # And I should not be logged in
  # 
  # Scenario: local account, linked with facebook, should be logged in automatically
  # Given I have a local account linked with Facebook
  # And I am logged in to Facebook
  # When I visit the home page
  # I should be logged in automatically via Facebook  

  
