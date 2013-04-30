require 'spec_helper'

describe "challenge_games/show" do

  before(:each) do
    @challenge_game = assign(:challenge_game, stub_model(ChallengeGame,word: "testers", choices: "t").decorate)
    view.stub!(:mxit_request?).and_return(false)
  end

  it "wont show the hangman text if game not started" do
    @challenge_game.started = nil
    render
    rendered.should_not have_content("t _ _ t _ _ _")
  end

  context "Game Started" do

    before(:each) do
      @challenge_game.started = true
      @challenge_game.stub!(:active_user).and_return(nil)
      @current_user = stub_model(User, id: 501)
      view.stub!(:current_user).and_return(@current_user)
    end

    it "must show the hangman text if game started" do
      render
      rendered.should have_content("t _ _ t _ _ _")
    end

    it "must show Opponent's Turn if not your turn" do
      @challenge_game.stub!(:active_user).and_return(stub_model(User))
      render
      rendered.should have_content("Opponent's Turn")
      rendered.should_not have_content("Your Turn")
    end

    context "Your Turn" do

      before(:each) do
        @challenge_game.stub!(:active_user).and_return(@current_user)
      end

      it "must show Your Turn if your turn" do
        render
        rendered.should have_content("Your Turn")
        rendered.should_not have_content("Opponent's Turn")
      end

      it "must have a letter link for each letter" do
        @challenge_game.stub!(:choices).and_return(nil)
        render
        ("a".."z").each do |letter|
          rendered.should have_link(letter, href: play_letter_challenge_game_path(@challenge_game,letter))
        end
      end

    end

  end

end
