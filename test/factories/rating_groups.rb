# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :rating_group do |f|
  f.association :person, :factory => :registered_user
  f.association :contribution, :factory => :comment
end
