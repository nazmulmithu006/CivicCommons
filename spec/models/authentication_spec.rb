require 'spec_helper'

describe Authentication do
  context "Associations" do
    it "should only belongs to a Person" do
      Authentication.reflect_on_association(:person).macro == :belongs_to
    end
  end
  context "validations" do
    it "should not have blank uid" do
      Authentication.create.errors[:uid].first.should == "can't be blank"
    end
    it "should not have blank provider" do
      Authentication.create.errors[:provider].first.should == "can't be blank" 
    end
    it "should not have blank person_id" do
      Authentication.create.errors[:person_id].first.should == "can't be blank" 
    end
    it "can only have one unique provider and uid at any given time" do
      auth1 = Factory.create(:authentication, :uid => '123',:provider => 'facebook')
      auth2 = Factory.build(:authentication, :uid => '123',:provider => 'facebook')
      auth2.valid?.should be_false
      auth2.errors[:uid].first.should == "has already been taken"
    end
  end
end