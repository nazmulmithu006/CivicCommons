Given /^I have a comment on the issue:$/ do |comment|
  FactoryGirl.create(:contribution,
                 person: @current_person,
                 content: comment,
                 conversation: nil,
                 issue: @issue)
end

Given /^an issue:$/ do |table|

  issue = table.rows_hash

  if issue['Image']
    attachment = File.open(File.join(attachments_path, issue['Image']))
  end

  @issue =
    FactoryGirl.create(:issue,
                   id:   issue['ID'],
                   name: issue['Name'],
                   image: attachment,
                   summary: issue['Summary'],
                   zip_code: issue['Zip Code'])

  @contributor = FactoryGirl.create(:registered_user)

  FactoryGirl.create(:issue_contribution,
                 issue: @issue,
                 owner: @contributor.id)

end

Given /^I am following the issue:$/ do |table|
  Given("an issue:", table)
  @issue.subscribe(@current_person)
end

Given /^I have a contribution on the issue$/ do
  FactoryGirl.create(:comment,
                 person: @current_person,
                 issue: @issue)
end

