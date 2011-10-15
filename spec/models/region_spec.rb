require 'spec_helper'


describe Region do

  describe "default" do
    it "has a name of national" do
      Region.default.name.should == "National"
    end

    it "has an id of 0" do
      Region.default.id.should == 0
    end

    it "default? is true" do
      Region.default.default?.should == true
    end
  end

  it "default is false" do
    Region.new.default? == false
  end

  it "joins zip_codes into a zip_code string" do
    zip_code = ZipCode.new :zip_code=>"11111"
    zip_code2 = ZipCode.new :zip_code=>"12345"
    region = Region.new
    region.name = "jake"
    region.zip_codes = [zip_code, zip_code2]
    region.zip_code_string = "11111\n12345"
  end

  it "returns empty strings when there are no zip_codes" do
    region = Region.new
    region.zip_code_string.should == ""
  end

  it "creates zip_codes based upon the zip_code string" do
    region = Region.new
    region.zip_code_string="12345\n11111"
    region.zip_codes.length.should == 2
    region.zip_codes.first.zip_code.should == "12345"
    region.zip_codes.last.zip_code.should == "11111"
  end

  describe "issues" do

    before(:each) do
      @issue = Factory.create(:issue, {:zip_code => "all"})
    end

    context "when region is default" do
      it "returns issues with 'all' zip_code" do
        Region.default.issues.should include(@issue)
      end
    end

    context "when region has zipcodes" do
      it "returns issues with 'all' zip_code" do
        region = Factory.create(:region,{:name => "blah"})
        region.zip_code_string = "48103\n18621"
        region.save
        Region.last.issues.should include(@issue)
      end
    end

    context "when region has no zipcodes" do
      it "returns issues for 'all' zip_code" do
        Region.new.issues.should include(@issue)
      end
    end
  end
  
  context "paperclip" do
    it "will have necessary db columns for paperclip" do
      should have_db_column(:image_file_name).of_type(:string)
      should have_db_column(:image_content_type).of_type(:string)
      should have_db_column(:image_file_size).of_type(:integer)
    end
    
    it "will only allow image attachments" do
      # allowed image mimetypes are based on what we have seen in production
      should validate_attachment_content_type(:image).
        allowing('image/bmp', 'image/gif', 'image/jpeg', 'image/png', 'image/pjpeg', 'image/x-png').
        rejecting('text/plain', 'text/xml')
    end
    
    it "should validate presence of attachemnt" do
      should validate_attachment_presence(:image)
    end    
  end
end
