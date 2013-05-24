require 'spec_helper'

describe ChallengeGame do

  context "Validation" do

    it "must generate a word" do
      Dictionary.should_receive(:random_value).and_return('wood')
      game = stub_model(ChallengeGame)
      game.save
      game.word.should == "wood"
    end

  end

  context "Associations" do

    it { should have_many(:participants).class_name('ChallengeGameParticipant') }

  end

  context "Scopes" do

    describe "completed" do

      it "returns completed games" do
        game = create(:challenge_game, state: 'completed')
        create(:challenge_game)
        ChallengeGame.completed.should == [game]
      end

    end

    describe "incompleted" do

      it "returns incomplete games" do
        create(:challenge_game, state: 'completed')
        game = create(:challenge_game)
        ChallengeGame.incompleted.should == [game]
      end

    end

    describe "started" do

      it "returns started games" do
        game = create(:challenge_game, state: 'started')
        create(:challenge_game)
        ChallengeGame.started.should == [game]
      end

    end

    describe "not_started" do

      it "returns not_started games" do
        create(:challenge_game, state: 'started')
        game = create(:challenge_game)
        ChallengeGame.not_started.should == [game]
      end

    end

    describe "waiting_for_opponent_game" do

      it "returns started games" do
        game = create(:challenge_game, state: 'waiting_for_opponent')
        create(:challenge_game)
        ChallengeGame.waiting_for_opponent.should == [game]
      end

    end

  end

  context "Instance Methods" do

    describe "active_player" do

      it "returns active player" do
        game = create(:challenge_game, state: 'started')
        player = create(:challenge_game_participant, active: true, challenge_game: game)
        create(:challenge_game_participant, active: false, challenge_game: game)
        create(:challenge_game_participant, active: true)
        game.active_player.should == player
      end

      it "returns nil if no player" do
        game = create(:challenge_game, state: 'started')
        create(:challenge_game_participant, active: false, challenge_game: game)
        create(:challenge_game_participant, active: true)
        game.active_player.should be_nil
      end

    end

    describe "active_player="  do

      before :each do
        @game = create(:challenge_game, state: 'started')
        @particpant1 = create(:challenge_game_participant, active: false, challenge_game: @game)
        @particpant2 = create(:challenge_game_participant, active: false, challenge_game: @game)
      end

      it "must allow to set active participant" do
        @game.active_player = @particpant1
        @particpant1.reload
        @particpant1.should be_active
        @game.active_player.should == @particpant1
      end

      it "must allow to change the active participant" do
        @game.active_player = @particpant1
        @game.active_player = @particpant2
        @particpant1.reload
        @particpant1.should_not be_active
        @particpant2.reload
        @particpant2.should be_active
        @game.active_player.should == @particpant2
      end

    end

  end

  context "Class Methods" do

    describe "find_for_user" do

      before :each do
        @user = create(:user)
      end

      it "must find active challenge game already part" do
        challenge_game = create(:challenge_game)
        create(:challenge_game_participant, active: false, challenge_game: challenge_game, user: @user)
        ChallengeGame.find_for_user(@user).should == challenge_game
      end

      it "must use game waiting for a opponent" do
        challenge_game = create(:challenge_game)
        challenge_game.add_player(create(:user).challenge_game_participants.build)
        ChallengeGame.find_for_user(@user).should == challenge_game
        @user.active_challenge_game.should == challenge_game
      end

      it "must return created game" do
        challenge_game = ChallengeGame.find_for_user(@user)
        @user.active_challenge_game.should == challenge_game
      end

    end

  end

end
