require "spec_helper"

describe ReflectionsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/conversations/1/reflections" }.should route_to(:controller => "reflections", :conversation_id => '1', :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/conversations/1/reflections/new" }.should route_to(:controller => "reflections", :conversation_id => '1', :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/conversations/1/reflections/1" }.should route_to(:controller => "reflections", :conversation_id => '1', :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/conversations/1/reflections/1/edit" }.should route_to(:controller => "reflections", :conversation_id => '1', :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/conversations/1/reflections" }.should route_to(:controller => "reflections", :conversation_id => '1', :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/conversations/1/reflections/1" }.should route_to(:controller => "reflections", :conversation_id => '1', :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/conversations/1/reflections/1" }.should route_to(:controller => "reflections", :conversation_id => '1', :action => "destroy", :id => "1")
    end

  end
end
