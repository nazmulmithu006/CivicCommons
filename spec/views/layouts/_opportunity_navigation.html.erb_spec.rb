require 'spec_helper'

describe 'layouts/_opportunity_navigation.html.erb' do
  let(:default_locals) do
    {
      conversation: FactoryGirl.create(:conversation),
      participants_count: 10,
      actions_count: 20,
      reflections_count: 30
    }
  end

  it "should render the /layouts/_opportunity_navigation_item template" do
    render partial: '/layouts/opportunity_navigation', locals: default_locals
    rendered.should render_template("/layouts/_opportunity_navigation_item")
  end

  it "should render the conversation_path" do
    render partial: '/layouts/opportunity_navigation', locals: default_locals
    rendered.should =~ /#{conversation_path(default_locals[:conversation])}/
  end

  it "should render the conversation_actions_path" do
    render partial: '/layouts/opportunity_navigation', locals: default_locals
    rendered.should =~ /#{conversation_actions_path(default_locals[:conversation])}/
  end

  it "should render participants_count" do
    render partial: '/layouts/opportunity_navigation', locals: default_locals
    rendered.should =~ /#{default_locals[:participants_count]}/
  end

  it "should render actions_count" do
    render partial: '/layouts/opportunity_navigation', locals: default_locals
    rendered.should =~ /#{default_locals[:actions_count]}/
  end

  it "should render reflections_count" do
    render partial: '/layouts/opportunity_navigation', locals: default_locals
    rendered.should =~ /#{default_locals[:reflections_count]}/
  end

  it "should render partial for 'Talk'" do
    render partial: '/layouts/opportunity_navigation', locals: default_locals
    rendered.should =~ /Talk/
  end

  it "should render partial for 'Take Action'" do
    render partial: '/layouts/opportunity_navigation', locals: default_locals
    rendered.should =~ /Take Action/
  end

  it "should render partial for 'Reflect'" do
    render partial: '/layouts/opportunity_navigation', locals: default_locals
    rendered.should =~ /Reflect/
  end
  
  it "should have the 'opportunity-nav' ID set in the nav bar" do
    render partial: '/layouts/opportunity_navigation', locals: default_locals
    rendered.should have_selector('div#opportunity-nav')
  end
  
  it "should have rendered with target of #opportunity-nav on conversation actions" do
    render partial: '/layouts/opportunity_navigation', locals: default_locals
    rendered.should have_selector("a[href='#{conversation_actions_path(default_locals[:conversation], :anchor => 'opportunity-nav')}']")
  end
  
  it "should have rendered with target of #opportunity-nav on conversation path" do
    render partial: '/layouts/opportunity_navigation', locals: default_locals
    rendered.should have_selector("a[href='#{conversation_path(default_locals[:conversation], :anchor => 'opportunity-nav')}']")
  end
  
  it "should have rendered with target of #opportunity-nav on conversation reflection path" do
    render partial: '/layouts/opportunity_navigation', locals: default_locals
    rendered.should have_selector("a[href='#{conversation_reflections_path(default_locals[:conversation], :anchor => 'opportunity-nav')}']")
  end
  
end
