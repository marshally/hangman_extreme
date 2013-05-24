require 'spec_thin_helper'
require 'state_machine'
require 'app/models/domain/play_challenge_game'

class DummyChallengeGame
  attr_accessor :state, :players, :active_player, :choices, :word

  def inactive_player
    (players - [active_player]).first
  end

  def initialize
    @players = []
    super
  end

  include Domain::PlayChallengeGame
end

describe Domain::PlayChallengeGame do

  describe 'new' do

    it "starts in created state" do
      DummyChallengeGame.new.should be_created
    end

  end

  describe 'add_player' do

    before :each do
      @game = DummyChallengeGame.new
    end

    context "First Player" do

      before :each do
        @game.add_player("player1")
      end

      it "must add the player" do
        @game.players.should include("player1")
      end

      it "must change the state to waiting_for_opponent" do
        @game.should be_waiting_for_opponent
      end

      context "Second Player" do

        it "must add the player" do
          @game.add_player("player2")
          @game.players.should include("player2")
        end

        it "must change the state to started" do
          @game.add_player("player2")
          @game.should be_started
        end

        it "must change select a active player" do
          @game.should_receive(:active_player=).with("player1")
          @game.add_player("player2")
        end

      end

    end

  end

  describe 'play_letter' do

    before :each do
      @game = DummyChallengeGame.new
      @game.state = 'started'
    end

    it "must add the choice" do
      @game.should_receive(:add_choice).with("b")
      @game.play_letter("b")
    end

    context "Incorrect Choice" do

      before :each do
        @game.stub!(:add_choice).and_return(false)
      end

      it "must switch players" do
        @game.should_receive(:switch_active_player)
        @game.play_letter("a")
      end

      it "wont check if game is done" do
        @game.should_not_receive(:done?)
        @game.play_letter("b")
      end

    end

    context "Correct Choice" do

      before :each do
        @game.stub!(:add_choice).and_return(true)
      end

      it "wont switch players" do
        @game.should_not_receive(:switch_active_player)
        @game.play_letter("b")
      end

      it "must check if game is done" do
        @game.should_receive(:done?)
        @game.play_letter("b")
      end

      context "Done" do

        before :each do
          @game.stub!(:done?).and_return(true)
        end

        it "must change the state to completed" do
          @game.play_letter("b")
          @game.should be_completed
        end

      end

    end

  end

  describe 'switch_active_player' do

    before :each do
      @game = DummyChallengeGame.new
      @game.add_player("player1")
      @game.add_player("player2")
    end

    it "must set the active_player to inactive" do
      @game.switch_active_player
      @game.active_player.should == "player2"
    end

    it "must set the inactive_player to active" do
      @game.switch_active_player
      @game.inactive_player.should == "player1"
    end

  end


  context "add_choice" do

    before :each do
      @game = DummyChallengeGame.new
      @game.state = 'started'
      @game.word = "test"
    end

    it "must allow to add choices" do
      @game.add_choice("a")
      @game.choices.should include("a")
    end

    it "must be true if right choice" do
      @game.add_choice("t").should be_true
    end

    it "must be false if wrong choice" do
      @game.add_choice("z").should be_false
    end

    it "wont allow to add choices if more than a letter" do
      @game.add_choice("ab")
      @game.choices.should_not include("a")
      @game.choices.should_not include("b")
    end

    it "must downcase letters" do
      @game.add_choice("C")
      @game.choices.should include("c")
    end

    it "must be able to add all letters" do
      ("a".."z").each do |letter|
        @game.add_choice(letter)
        @game.choices.should include(letter)
      end
      ("1".."9").each do |number|
        @game.add_choice(number)
        @game.choices.should_not include(number)
      end
    end

  end

  describe 'done?' do

    before :each do
      @game = DummyChallengeGame.new
      @game.word = "test"
    end

    it "must be done if all letters present in choices" do
      @game.choices = "ste"
      @game.should be_done
    end

    it "wont be done if all letters not present in choices" do
      @game.choices = "stajki"
      @game.should_not be_done
    end

  end

end
