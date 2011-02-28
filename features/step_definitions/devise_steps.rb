ACCESS_TOKEN = {
  :access_token => "ccfaketoken"
}

FACEBOOK_INFO =  {
  :id => '12345',
  :link => 'http://facebook.com/user_example',
  :email => 'johndoe@civiccomons.com',
  :first_name => 'John',
  :last_name => 'Doe',
  :website => 'http://blog.civiccommons.com'
}

When /^Facebook reply$/ do 
  Devise::OmniAuth.short_circuit_authorizers!
  Devise::OmniAuth.stub!(:facebook) do |b|
    b.post('/oauth/access_token') { [200, {}, ACCESS_TOKEN.to_json] }
    b.get('/me?access_token=ccfaketoken') { [200, {}, FACEBOOK_INFO.to_json] }
  end

  visit '/people/auth/facebook/callback'
end