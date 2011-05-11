require 'spec_helper'

describe Vote do
  describe "Single Table Inheritance" do
    it "should inherit from Survey" do
      Vote.superclass.should == Survey
    end
  end
end