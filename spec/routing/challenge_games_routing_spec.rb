require "spec_helper"

describe ChallengeGamesController do
  describe "routing" do

    it "routes to #index" do
      get("/challenge_games").should route_to("challenge_games#index")
    end

    it "routes to #new" do
      get("/challenge_games/new").should route_to("challenge_games#new")
    end

    #it "routes to #play" do
    #  get("/challenge_games/play").should route_to("challenge_games#play")
    #end

    it "routes to #show" do
      get("/challenge_games/1").should route_to("challenge_games#show", :id => "1")
    end


    it "routes to #show" do
      get("/challenge_games/1/letter/a").should route_to("challenge_games#play_letter", id: "1", letter: "a")
    end

    #it "routes to #show_clue" do
    #  get("/games/1/show_clue").should route_to("games#show_clue", id: "1")
    #end
    #
    #it "routes to #show_clue" do
    #  post("/games/1/show_clue").should route_to("games#reveal_clue", id: "1")
    #end

  end
end
