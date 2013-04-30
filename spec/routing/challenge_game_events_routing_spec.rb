require "spec_helper"

describe ChallengeGameEventsController do
  describe "routing" do

    it "routes to #index" do
      get("/challenge_games/1/events").should route_to("challenge_game_events#index", :challenge_game_id => "1")
    end

  end
end
