# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :region do |f|
  f.name "MyString"
  f.image File.new(Rails.root + 'test/fixtures/images/test_image.jpg')
end
