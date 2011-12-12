require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "8457517 link local account with facebook", %q{
  In order use CivicCommons
  As an existing user with a local account
  I want to authenticate through Facebook
  So that I only have to remember one login and password
} do
  include Facebookable
  before do
    stub_facebook_auth
    login_page.sign_out
  end

  let (:facebook_auth_page) { FacebookAuthPage.new(page) }
  let (:login_page)                 { LoginPage.new(page) }
  let (:settings_page)              { SettingsPage.new(page) }
  let (:fb_linking_success_page)    { FbLinkingSuccessPage.new(page) }
  let (:suggest_facebook_auth_page) { SuggestFacebookAuthPage.new(page) }
  let (:forgot_password_page)       { ForgotPasswordPage.new(page) }
  let (:fb_auth_forgot_password_modal_page) { FbAuthForgotPasswordModalPage.new(page)}

  def response_should_js_redirect_to(path)
    page.should contain "window.opener.location = '#{path}'"
  end

  def response_should_js_open_colorbox(path)
    page.should contain "$.colorbox({href:'#{path}'"
  end


  context "When I have not linked my account to Facebook" do

    scenario "use facebook email if conflicting", :js=>true do
      login_as :registered_user
      begin_connecting_to_facebook
      use_facebook_email
      reload_logged_in_user
      logged_in_user.email.should == 'johnd@test.com'
    end


    scenario "I should be able to link my account to facebook from the 'accounts' page", :js=>true do
      login_as :registered_user, email: 'johnd@test.com'
      connect_account_to_facebook
      logged_in_user.should be_facebook_authenticated
      page.should_not have_link 'Connect with Facebook'
      page.should have_link "Unlink from Facebook"
    end

    describe "Facebook suggest modal dialogue" do
      scenario "should be displayed if I have not linked my account to facebook" do
        login_as :registered_user_who_hasnt_declined_fb
        page.should contain suggest_facebook_auth_page.modal
      end
      scenario "should be not be displayed when I have declined the suggestion to link to Facebook" do
        login_as :registered_user_with_facebook_email

        # Then I should see a suggestion for Facebook link modal
        page.should contain suggest_facebook_auth_page.modal

        # And I declined the Suggest Facebook auth page
        suggest_facebook_auth_page.click_decline

        # And I logged out
        login_page.sign_out

        # When I logged in again
        login_page.sign_in(@person)

        # Then I should not see the suggest modal
        page.should_not contain suggest_facebook_auth_page.modal
      end
    end
  end

  context "When I already have linked my account to facebook previously" do

    def given_a_registered_user_w_facebook_auth
      @person = Factory.create(:registered_user)
      @facebook_auth = Factory.build(:facebook_authentication)
      @person.link_with_facebook(@facebook_auth)
    end

    scenario "I should be able to login using facebook and to existing account" do
      # Given I am a registered user with Facebook Auth
      given_a_registered_user_w_facebook_auth

      # When I visit the homepage
      visit homepage

      # Then I should have the link 'Sign in with Facebook'
      page.should have_link 'Sign in with Facebook'

      # And I should not have my name on the site(because I haven't logged in yet)
      page.should_not have_content "John Doe"

      # When I sign in using Facebook
      facebook_auth_page.sign_in

      # Then it should give me a javascript to redirect me to the homepage
      response_should_js_redirect_to(homepage)
      visit homepage

      # And I should not see the link 'Sign in with Facebook' anymore
      page.should_not have_link 'Sign in with Facebook'

      # And I should see my name there
      page.should have_content "John Doe"
    end

    scenario "I should not be able to login using my existing account anymore" do
      # Given I am a registered user that have connected my account with facebook
      given_a_registered_user_w_facebook_auth

      # When I am on the homepage
      visit homepage

      # And I try to sign in
      login_page.sign_in(@person)

      # Then I should not be able to login, and should display the proper message
      page.should have_content 'It looks like you registered using Facebook, please login with Facebook.'
    end

  end

  context "Facebook profile picture" do

    def user_profile_picture
      page.find('#login-status a img')['src']
    end

    scenario "I should my facebook profile picture if I've connected to Facebook" do
      login_as :registered_user_with_avatar
      connect_account_to_facebook
      header.user_profile_picture.should be_of "https://graph.facebook.com/12345/picture"
    end
  end

  context "Forgot password" do
    def given_a_registered_user_w_facebook_auth_w_email(email)
      @person = Factory.create(:registered_user,:email => email)
      @facebook_auth = Factory.build(:facebook_authentication)
      @person.link_with_facebook(@facebook_auth)
    end
    scenario "I should see a modal dialog prompting me to login to facebook." do
      # Given I am a registered user with facebook account
      given_a_registered_user_w_facebook_auth_w_email('johnd@example.com')

      # when I am on the forgot password page
      forgot_password_page.visit

      # when I enter my email
      forgot_password_page.enter_email('johnd@example.com')

      # when I click submit
      forgot_password_page.click_submit

      # then I should see modal dialog prompting me to login using Facebook instead
      response_should_js_open_colorbox(fb_auth_forgot_password_path)
      fb_auth_forgot_password_modal_page.visit

      # then the modal should have link to sign in using facebook
      page.should have_link "Sign in with Facebook"
    end
  end
  def connect_account_to_facebook
    begin_connecting_to_facebook
    submit
    reload_logged_in_user
  end
  def begin_connecting_to_facebook
    page_header.follow_settings_link :for => logged_in_user
    follow_connect_to_facebook_link
  end
end
