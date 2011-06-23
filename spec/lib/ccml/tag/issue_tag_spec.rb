require 'spec_helper'

describe CCML::Tag::IssueTag do

  context "'index' method" do

    before(:each) do
      @issue = Factory.create(:issue)
      @url = "http://www.theciviccommons.com/issues/#{@issue.cached_slug}"
      @tag_body = '{id} "{name}" {cached_slug}'
      @tag_regexp = Regexp.new("#{@issue.id} \"#{@issue.name}\" #{@issue.cached_slug}")
    end

    it "accepts an id as opts id" do
      tag = CCML::Tag::IssueTag.new({id: @issue.id}, @url)
      tag.tag_body = @tag_body
      tag.index.should =~ @tag_regexp
    end

    it "accepts a cached_slug as opts id" do
      tag = CCML::Tag::IssueTag.new({id: @issue.cached_slug}, @url)
      tag.tag_body = @tag_body
      tag.index.should =~ @tag_regexp
    end

    it "gets the id from segment 1 if no id is given" do
      tag = CCML::Tag::IssueTag.new({}, @url)
      tag.tag_body = @tag_body
      tag.index.should =~ @tag_regexp
    end

    it "returns blank if the requested issue is not found" do
      tag = CCML::Tag::IssueTag.new({id: 0}, @url)
      tag.tag_body = @tag_body
      tag.index.should be_blank
    end

  end

  context "'pages' method" do

    before(:each) do
      @issue = Factory.create(:managed_issue)
      @page = Factory.create(:managed_issue_page, issue: @issue)
      @url = "http://www.theciviccommons.com/issues/#{@issue.cached_slug}"
      @tag_body = '{id} "{name}" {cached_slug}'
      @tag_regexp = Regexp.new("#{@page.id} \"#{@page.name}\" #{@page.cached_slug}")
    end

    it "accepts an id as opts id" do
      tag = CCML::Tag::IssueTag.new({id: @issue.id}, @url)
      tag.tag_body = @tag_body
      tag.pages.should =~ @tag_regexp
    end

    it "accepts a cached_slug as opts id" do
      tag = CCML::Tag::IssueTag.new({id: @issue.cached_slug}, @url)
      tag.tag_body = @tag_body
      tag.pages.should =~ @tag_regexp
    end

    it "gets the id from segment 1 if no id is given" do
      tag = CCML::Tag::IssueTag.new({}, @url)
      tag.tag_body = @tag_body
      tag.pages.should =~ @tag_regexp
    end

    it "returns blank if the requested issue is not found" do
      tag = CCML::Tag::IssueTag.new({id: 0}, @url)
      tag.tag_body = @tag_body
      tag.pages.should be_blank
    end

    it "returns blank if the requested issue has no associated pages" do
      issue = Factory.create(:managed_issue)
      tag = CCML::Tag::IssueTag.new({id: issue.id}, @url)
      tag.tag_body = @tag_body
      tag.pages.should be_blank
    end

    it "returns blank if the requested issue is not a managed issue" do
      issue = Factory.create(:issue)
      tag = CCML::Tag::IssueTag.new({id: issue.id}, @url)
      tag.tag_body = @tag_body
      tag.pages.should be_blank
    end

  end

  context "'conversations' method" do

    before(:each) do
      @issue = Factory.create(:managed_issue)
      @convo = Factory.create(:conversation)
      @convo.issues << @issue
      @convo.save
      @url = "http://www.theciviccommons.com/issues/#{@issue.cached_slug}"
      @tag_body = '{id} "{title}"'
      @tag_regexp = Regexp.new("#{@convo.id} \"#{@convo.title}\"")
    end

    it "accepts an id as opts id" do
      tag = CCML::Tag::IssueTag.new({id: @issue.id}, @url)
      tag.tag_body = @tag_body
      tag.conversations.should =~ @tag_regexp
    end

    it "accepts a cached_slug as opts id" do
      tag = CCML::Tag::IssueTag.new({id: @issue.cached_slug}, @url)
      tag.tag_body = @tag_body
      tag.conversations.should =~ @tag_regexp
    end

    it "gets the id from segment 1 if no id is given" do
      tag = CCML::Tag::IssueTag.new({}, @url)
      tag.tag_body = @tag_body
      tag.conversations.should =~ @tag_regexp
    end

    it "returns blank if the requested issue is not found" do
      tag = CCML::Tag::IssueTag.new({id: 0}, @url)
      tag.tag_body = @tag_body
      tag.conversations.should be_blank
    end

    it "returns blank if the requested issue has no associated conversations" do
      issue = Factory.create(:managed_issue)
      tag = CCML::Tag::IssueTag.new({id: issue.id}, @url)
      tag.tag_body = @tag_body
      tag.conversations.should be_blank
    end

    it "aliases a 'convos' method as an alternative to 'conversations'" do
      tag = CCML::Tag::IssueTag.new({id: @issue.id}, @url)
      tag.tag_body = @tag_body
      tag.conversations.should == tag.convos
    end

  end

  context "'vote_band' method" do
    before(:each) do
      @issue = Factory.create(:issue)
      @vote1 = Factory.create(:vote, :title => 'Vote1title', :surveyable_type => @issue.class.name, :surveyable_id => @issue.id)
      @vote2 = Factory.create(:vote, :title => 'Vote2title', :surveyable_type => @issue.class.name, :surveyable_id => @issue.id)
      @url = "http://www.theciviccommons.com/issues/#{@issue.cached_slug}"
      @vote_title1 = Regexp.new(@vote1.title)
      @vote_title2 = Regexp.new(@vote2.title)
    end
    
    it "accepts an id as opts id" do
      tag = CCML::Tag::IssueTag.new({id: @issue.id}, @url)
      tag.vote_band.should =~ @vote_title1
      tag.vote_band.should =~ @vote_title2
    end
    
    it "accepts a cached_slug as opts id" do
      tag = CCML::Tag::IssueTag.new({id: @issue.cached_slug}, @url)
      tag.vote_band.should =~ @vote_title1
      tag.vote_band.should =~ @vote_title2
    end
    
    it "accepts limit and correctly displays it" do
      tag = CCML::Tag::IssueTag.new({id: @issue.cached_slug, limit: 1}, @url)
      tag.vote_band.should =~ @vote_title1
      tag.vote_band.should_not =~ @vote_title2
    end
    
  end
end
