require 'spec_helper'

describe Poll do
  describe "Single Table Inheritance" do
    it "should inherit from Survey" do
      Poll.superclass.should == Survey
    end
  end
end