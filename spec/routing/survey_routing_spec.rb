require "spec_helper"

describe SurveysController do
  describe "routing" do

    it "recognizes and generates #show on Issue" do
      { get: "/issues/1/vote" }.should route_to(controller: "surveys", action: "show", type: 'vote', issue_id: '1')
    end

    it "recognizes and generates #show on Issue" do
      { get: "/conversations/1/vote" }.should route_to(controller: "surveys", action: "show", type: 'vote', conversation_id: '1')
    end

  end
end
