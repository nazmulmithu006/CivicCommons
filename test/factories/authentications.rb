# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :authentication do |f|
  f.provider "MyString"
  f.uid "MyString"
  f.token "MyString"
  f.secret "MyString"
  f.association :person, :factory => :normal_person, :first_name => 'Marc', :last_name => 'Canter'
end