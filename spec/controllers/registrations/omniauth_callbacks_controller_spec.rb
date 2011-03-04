require 'spec_helper'

describe Registrations::OmniauthCallbacksController, "handle facebook authentication callback" do
  def stub_successful_auth
    # inspired by https://gist.github.com/792715
    # See https://github.com/plataformatec/devise/issues/closed#issue/608
    request.env["devise.mapping"] = Devise.mappings[:person]
    env = { "omniauth.auth" => { "provider" => "facebook", "uid" => "12345", "extra" => { "user_hash" => { "email" => "ghost@nobody.com" } } } }
    @controller.stub!(:env).and_return(env)
  end
  
  def stub_failed_auth
    # inspired by https://gist.github.com/792715
    # See https://github.com/plataformatec/devise/issues/closed#issue/608
    request.env["devise.mapping"] = Devise.mappings[:person]
    env = { "omniauth.auth" => {} }
    @controller.stub!(:env).and_return(env)
  end
  
  describe "facebook" do
    context "logged in and linking account with facebook" do
      def given_a_registered_user
        @person = Factory.create(:registered_user)
      end
      it "should successfully link the account to facebook" do
        stub_successful_auth
        given_a_registered_user
        @person.authentications.count.should == 0
        sign_in @person
        get :facebook
        @person.facebook_authenticated?.should be_true
        @person.authentications.count.should == 1
        flash[:notice].should == "Successfully linked your accaunt to Facebook"
      end
      it "should not link the account to facebook when failed authentication" do
        stub_failed_auth
        given_a_registered_user
        @person.authentications.count.should == 0
        sign_in @person
        get :facebook
        @person.facebook_authenticated?.should be_false
        @person.authentications.count.should == 0
        flash[:notice].should == "Could not link your accaunt to Facebook"
      end
    end
    context "Not logged in and logging in using facebook" do
      pending
    end
  end

end
