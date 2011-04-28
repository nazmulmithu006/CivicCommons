require "spec_helper"

describe Admin::SurveysController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/admin/surveys" }.should route_to(:controller => "admin/surveys", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/admin/surveys/new" }.should route_to(:controller => "admin/surveys", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/admin/surveys/1" }.should route_to(:controller => "admin/surveys", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/admin/surveys/1/edit" }.should route_to(:controller => "admin/surveys", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/admin/surveys" }.should route_to(:controller => "admin/surveys", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/admin/surveys/1" }.should route_to(:controller => "admin/surveys", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/admin/surveys/1" }.should route_to(:controller => "admin/surveys", :action => "destroy", :id => "1")
    end

  end
end
