require "spec_helper"

describe SurveysController do
  describe "routing" do
    describe "#show" do      
      it "recognizez #show independently on /votes" do
        { get: "/votes/1" }.should route_to(controller: "surveys", action: "show", id: '1')
      end
    end
    describe "create_response" do      
      it "recognizez #create_response independently on /votes" do
        { post: "/votes/1/create_response" }.should route_to(controller: "surveys", action: "create_response", id: '1')
      end
      
    end
  end
end
