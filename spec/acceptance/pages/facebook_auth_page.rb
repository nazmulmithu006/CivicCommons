class FacebookAuthPage
  ACCESS_TOKEN = {
    :access_token => "ccfaketoken"
  }

  FACEBOOK_INFO = {
    :id => '12345',
    :link => 'http://facebook.com/user_example',
    :email => 'johndoe@civiccomons.com',
    :first_name => 'John',
    :last_name => 'Doe',
    :website => 'http://blog.civiccommons.com'
  }
  
  def initialize(page)
    @page = page 
  end

  def reset_stubs!
    Devise::OmniAuth.unshort_circuit_authorizers!
    Devise::OmniAuth.reset_stubs!(:facebook)
  end

  def sign_in
    @page.click_link_or_button 'Sign in with Facebook'
    stub_omniauth
    visit_callback
    reset_stubs!
  end
  
  def link_account
    @page.click_link_or_button "Link my account with Facebook"
    stub_omniauth 
    visit_callback
    reset_stubs!
  end
  
  def click_connect_with_facebook
    stub_omniauth
    @page.click_link_or_button "Connect with Facebook"
    visit_callback
    reset_stubs!
  end

  def stub_omniauth
    Devise::OmniAuth.short_circuit_authorizers!
    Devise::OmniAuth.stub!(:facebook) do |b|
      b.post('/oauth/access_token') { [200, {}, ACCESS_TOKEN.to_json] }
      b.get('/me?access_token=ccfaketoken') { [200, {}, FACEBOOK_INFO.to_json] }
    end
  end


  def visit_callback
    @page.visit '/people/auth/facebook/callback'
  end

end