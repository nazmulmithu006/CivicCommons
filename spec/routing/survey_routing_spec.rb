require "spec_helper"

describe SurveysController do
  describe "routing" do
    describe "#show" do
      it "recognizes and generates #show on Issue" do
        { get: "/issues/1/vote" }.should route_to(controller: "surveys", action: "show", issue_id: '1')
      end

      it "recognizes and generates #show on Conversation" do
        { get: "/conversations/1/vote" }.should route_to(controller: "surveys", action: "show", conversation_id: '1')
      end
      
      it "recognizez #show independently on /votes" do
        { get: "/votes/1" }.should route_to(controller: "surveys", action: "show", id: '1')
      end
    end
    describe "create_response" do
      it "recognizes and generates #create_response on Issue" do
        { post: "/issues/1/vote/create_response" }.should route_to(controller: "surveys", action: "create_response", issue_id: '1')
      end

      it "recognizes and generates #create_response on Conversation" do
        { post: "/conversations/1/vote/create_response" }.should route_to(controller: "surveys", action: "create_response", conversation_id: '1')
      end
      
      it "recognizez #create_response independently on /votes" do
        { post: "/votes/1/create_response" }.should route_to(controller: "surveys", action: "create_response", id: '1')
      end
      
    end
  end
end
