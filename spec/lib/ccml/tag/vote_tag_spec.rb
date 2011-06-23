require 'spec_helper'

describe CCML::Tag::VoteTag do
  context "'index' method" do
    before(:each) do
      @vote1 = Factory.create(:vote, :title => 'Vote1title')
      @vote2 = Factory.create(:vote, :title => 'Vote2title')
      @url = "http://www.theciviccommons.com/whatever/url"
      @vote_title1 = Regexp.new(@vote1.title)
      @vote_title2 = Regexp.new(@vote2.title)
    end
    
    it "accepts an id as opts id" do
      tag = CCML::Tag::VoteTag.new({id: @vote1.id}, @url)
      tag.index.should =~ @vote_title1
    end
        
    it "accepts limit and correctly displays the limit" do
      tag = CCML::Tag::VoteTag.new({id: @vote1.id, limit: 1}, @url)
      tag.index.should =~ @vote_title1
      tag.index.should_not =~ @vote_title2
    end
    
    it "accepts no argument" do
      tag = CCML::Tag::VoteTag.new({}, @url)
      tag.index.should =~ @vote_title1
      tag.index.should =~ @vote_title2
      
    end
    
  end
  
end