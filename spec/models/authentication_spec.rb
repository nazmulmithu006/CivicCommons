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
  context "omniauth" do
    describe "building authentication model from omniauth hash" do
      def given_an_authentication_from_hash
        #This hash is taken from an actual facebook hash. scrubbed of personal identifiable information.
        @hash = {"provider"=>"facebook", 
                "uid"=>"123456107280617", 
                "credentials"=>{"token"=>"1234567890"}, 
                "user_info"=>{"nickname"=>"profile.php?id=123456107280617", "first_name"=>"John", "last_name"=>"Doe", "name"=>"John Doe", "urls"=>{"Facebook"=>"http://www.facebook.com/profile.php?id=123456107280617", "Website"=>nil}}, 
                "extra"=>{"user_hash"=>{
                  "id"=>"123456107280617", 
                  "name"=>"John Doe", 
                  "first_name"=>"John", 
                  "last_name"=>"Doe", 
                  "link"=>"http://www.facebook.com/profile.php?id=123456107280617", 
                  "gender"=>"male", 
                  "email"=>"apps+123456789012345.123456107280617.e649a19ed7c6b5433a88eb00a653d08e@proxymail.facebook.com", 
                  "timezone"=>-5, 
                  "locale"=>"en_US", 
                  "updated_time"=>"2010-03-10T23:53:20+0000"}}}
        @authentication = Authentication.new_from_auth_hash(@hash)
      end
      it "should have uid" do
        given_an_authentication_from_hash
        @authentication.uid.should == "123456107280617"
      end
      it "should have provider" do
        given_an_authentication_from_hash
        @authentication.provider.should == 'facebook'
      end
      it "should find the authentication based on the hash" do
        given_an_authentication_from_hash
        @authentication.person_id = 1
        @authentication.save
        Authentication.find_from_auth_hash(@hash).should == @authentication
      end
    end
  end
end