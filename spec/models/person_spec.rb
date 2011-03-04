require 'spec_helper'

describe Person do
  subject { Factory.build(:normal_person) }

  it { should be_valid }
  it { should have_attached_file :avatar }
  it { should validate_attachment_content_type(:avatar).allowing(["image/gif", "image/jpeg", "image/png"])
                .rejecting(['text/plain']) }
end

describe Person do
  context "Associations" do
    it "should has_many Authentications" do
      Person.reflect_on_association(:authentications).macro == :has_many
    end
  end

  describe "validate required data" do

    before(:each) do
      @person = Factory.build(:normal_person)
    end

    it "should require first name or last name" do
      @person.first_name = ''
      @person.last_name = ''
      @person.should_not be_valid
    end

    it "should require email address" do
      @person.email = ''
      @person.should_not be_valid
    end

    it "should require zip_code" do
      @person.zip_code = ''
      @person.should_not be_valid
    end

  end

  describe "when parsing the name" do
    it "should parse simple name" do
      first, last = Person.parse_name("John Doe")
      first.should == "John"
      last.should == "Doe"
    end

    it "should have blank last name when missing" do
      first, last = Person.parse_name("John")
      first.should == "John"
      last.should == ""
    end

    it "should handle complex last name" do
      first, last = Person.parse_name("John van Buren")
      first.should == "John"
      last.should == "van Buren"
    end

    it "should handle multi names" do
      first, last = Person.parse_name("Gladys s.w. Lum")
      first.should == "Gladys"
      last.should == "s.w. Lum"
    end

    it "should strip extra whitespace between name parts" do
      first, last = Person.parse_name("  The Grand       Duchess of Windsor  ")
      [first, last].join(" ").should == "The Grand Duchess of Windsor"
    end
  end

  describe "when finding all by name" do

    def given_a_person_with_name(name)
      person = Factory.create(:normal_person)
      person.name = name
      person.password = "password"
      person.email = "wendy@example.com"
      person.save!
      person
    end

    it "should find when only first name exists" do
      person = given_a_person_with_name "Wendy"
      Person.find_all_by_name("Wendy").should == [person]
    end

    it "should find when first and last name" do
      person = given_a_person_with_name "Wendy Smith"
      Person.find_all_by_name("Wendy Smith").should == [person]
    end

    it "should find when first and last has prefix" do
      person = given_a_person_with_name "Wendy van Buren"
      Person.find_all_by_name("Wendy van Buren").should == [person]
    end
  end

  describe "when setting the name" do
    it "should split the entry into first name and last name" do
      person = Factory.create(:normal_person)
      person.name = "John Doe"
      person.first_name.should == "John"
      person.last_name.should == "Doe"
    end
  end

  context "when setting the email address" do
    it "should not allow emails that are too short" do
      person = Factory.build(:normal_person, :email => "a@b.c")
      person.valid?.should be_false
      person.should have_validation_error(:email, /please use a longer email address/)
    end

    it "should not allow emails that are too long" do
      person = Factory.build(:normal_person, :email => "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890@1234567890b.c")
      person.valid?.should be_false
      person.should have_validation_error(:email, /please use a shorter email address/)
    end
  end

  describe "when displaying a name" do
    it "should respect case of name entered by person" do
      person = Factory.build(:normal_person)
      person.first_name = "ektor"
      person.last_name = "van capsula"
      person.name.should == "ektor van capsula"
    end

    it "should display names without leading spaces when the first name is missing" do
      person = Factory.build(:normal_person)
      person.first_name = ""
      person.last_name = "van capsula"
      person.name.should == "van capsula"
    end

    it "should display names without trailing spaces when the last name is missing" do
      person = Factory.build(:normal_person)
      person.first_name = "ektor"
      person.last_name = ""
      person.name.should == "ektor"
    end
  end

  describe "upon creation" do
    before(:each) do
      ActionMailer::Base.deliveries = []
    end
    def given_a_new_user_registered
      @person = Factory.create(:normal_person)
      @person.first_name = 'John'
      @person.last_name = 'Doe'
      @person.save
    end
    it "should send a confirmation email" do
      given_a_new_user_registered
      mailing = ActionMailer::Base.deliveries.first
      mailing[:from].to_s.should == Civiccommons::Config.devise_email
      mailing.to.should == [@person.email]
      mailing.subject.should == "Confirmation instructions"
    end

    it "should not send a welcome email" do
      given_a_new_user_registered
      mailing = ActionMailer::Base.deliveries.last
      mailing.subject.should_not == "Welcome to The Civic Commons"
    end

    it "should send a notification email to register@civiccommons.com" do
      given_a_new_user_registered
      mailing = ActionMailer::Base.deliveries.last
      mailing[:from].to_s.should == Civiccommons::Config.devise_email
      mailing.to.should == ["register@theciviccommons.com"]
      mailing.subject.should == "New User Registered"
      mailing.body.include?(@person.email).should be_true
    end
  end
  describe "after confirmation of email" do
    it "should send a welcome email" do
      ActionMailer::Base.deliveries = []
      person = Factory.create(:normal_person)

      mailing = ActionMailer::Base.deliveries.last
      mailing.subject.should_not == "Welcome to The Civic Commons"

      person.confirmed_at = Time.now
      person.save

      person.confirmed_at.should_not be_blank

      mailing = ActionMailer::Base.deliveries.last
      mailing[:from].to_s.should == Civiccommons::Config.devise_email
      mailing.to.should == [person.email]
      mailing.subject.should == "Welcome to The Civic Commons"
      ActionMailer::Base.deliveries.length.should == 3
      person.save
      ActionMailer::Base.deliveries.length.should == 3
    end
  end

  context "Facebook authentication" do
    describe "when having a facebook authentication associated" do
      def given_a_person_with_facebook_auth
        @person = Factory.build(:normal_person)
        @authentication = Factory.build(:authentication, :provider => 'facebook')
        @person.link_with_facebook(@authentication)
      end
      it "should show that it does have the correct authentication" do
        given_a_person_with_facebook_auth
        @person.facebook_authentication.should == @authentication
        @person.facebook_authentication.should be_persisted
      end
      it "should return true if an account is facebook authenticated" do
        given_a_person_with_facebook_auth
        @person.facebook_authenticated?.should be_true
      end
      it "should wiped out the current person's password, so they can't login using local account anymore" do
        @person = Factory.create(:normal_person, :password => 'password')
        @person.valid_password?('password').should be_true
        @authentication = Factory.build(:authentication, :provider => 'facebook')
        @person.link_with_facebook(@authentication)
        @person.valid_password?('password').should be_false 
      end
    end
    describe "link_with_facebook" do
      it "should return true if correctly saved" do
        @person = Factory.build(:normal_person)
        @authentication = Factory.build(:authentication, :provider => 'facebook')
        @person.link_with_facebook(@authentication).should be_true
      end
      it "should return false if incorrectly saved" do
        @person = Factory.build(:normal_person)
        @authentication = Authentication.new
        @person.link_with_facebook(@authentication).should be_false
      end
    end
    describe "when an account is not facebook authenticated" do
      it "should return false if we check for it" do
        @person = Factory.build(:normal_person)
        @person.facebook_authenticated?.should be_false 
      end
    end
  end
end
