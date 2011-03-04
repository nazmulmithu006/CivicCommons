require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "8457517 link local account with facebook", %q{
  In order use CivicCommons
  As an existing user with a local account
  I want to authenticate through Facebook
  So that I only have to remember one login and password
} do
  
  before do
    login_page.sign_out
  end

  let :facebook_auth_page do
    FacebookAuthPage.new(page)
  end
  
  let :login_page do
    LoginPage.new(page)
  end
  
  describe "When I have not linked my account to Facebook" do
    
    def given_a_registered_user
      @person = Factory.create(:registered_user)
    end

    scenario "I should be able to link my account to facebook" do
      given_a_registered_user
      visit homepage
      login_page.sign_in(@person)
      page.should have_link "Link my account with Facebook"
      facebook_auth_page.link_account
      should_be_on homepage
      page.should have_content "John Doe"
      page.should_not have_link "Link my account with Facebook"
    end

  end

  describe "When I already have linked my account to facebook previously" do
    
    def given_a_registered_user_w_facebook_auth
      @person = Factory.create(:registered_user)
      @facebook_auth = Factory.build(:facebook_authentication)
      @person.link_with_facebook(@facebook_auth)
    end

    scenario "I should be able to login using facebook and to existing account" do
      given_a_registered_user_w_facebook_auth
      visit homepage
      page.should have_link 'Sign in with Facebook'
      page.should_not have_content "John Doe"
      facebook_auth_page.sign_in
      should_be_on homepage
      page.should_not have_link 'Sign in with Facebook'
      page.should have_content "John Doe"      
    end
    
    scenario "I should not be able to login using my existing account anymore" do
      given_a_registered_user_w_facebook_auth
      visit homepage
      login_page.sign_in(@person)
      page.should have_content "Invalid email or password."
    end
  end
end