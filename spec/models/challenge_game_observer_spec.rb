require 'spec_helper'

describe ChallengeGameObserver do

  describe "after_save" do

    before :each do
      @redis_connection = mock("MockRedis", publish: true)
      @game_observer = ChallengeGameObserver.instance
      @game_observer.stub!(:redis_connection).and_return(@redis_connection)
    end

    it "must publish that game has just_started" do
      game = stub_model(ChallengeGame, id: 10, choices: "a")
      @redis_connection.should_receive(:publish).
        with("challenge_game_10", ([game.attributes.merge(word: nil),{event: 'updated'}]).to_json)
      @game_observer.after_save(game)
    end

  end

end
