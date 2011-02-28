Given /^I have a confirmed local user account$/ do
  @current_person = Factory.create(:registered_user)
end

Given /^I am logged in$/ do
  visit '/people/login'
  fill_in 'person[email]', with: @current_person.email
  fill_in 'person[password]', with: 'password'
  click_button 'person_submit'
end

Then /^I should receive an? "([^"]*)" with the message:$/ do |error, string|
  @code_to_run.should raise_error(error.constantize, string)
end

