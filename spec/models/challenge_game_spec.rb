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
    it { should have_one(:active_participant).class_name('ChallengeGameParticipant') }
    it { should have_one(:active_user).through(:active_participant).class_name('User') }
    it { should have_many(:users).through(:participants).class_name('User') }

  end

  context "Scopes" do

    describe "completed" do

      it "returns completed games" do
        game = create(:challenge_game, completed: true)
        create(:challenge_game, completed: nil)
        create(:challenge_game, completed: false)
        ChallengeGame.completed.should == [game]
      end

    end

    describe "incompleted" do

      it "returns incompleted games" do
        create(:challenge_game, completed: true)
        game1 = create(:challenge_game, completed: nil)
        game2 = create(:challenge_game, completed: false)
        ChallengeGame.incompleted.should include(game1,game2)
        ChallengeGame.incompleted.count.should == 2
      end

    end

    describe "started" do

      it "returns started games" do
        game = create(:challenge_game, started: true)
        create(:challenge_game, started: nil)
        create(:challenge_game, started: false)
        ChallengeGame.started.should == [game]
      end

    end

    describe "not_started" do

      it "returns not_started games" do
        create(:challenge_game, started: true)
        game1 = create(:challenge_game, started: nil)
        game2 = create(:challenge_game, started: false)
        ChallengeGame.not_started.should include(game1,game2)
        ChallengeGame.not_started.count.should == 2
      end

    end

  end

  context "Instance Methods" do

    describe "add_user" do

      it "must add the user to the game" do
        game = create(:challenge_game)
        user1 = create(:user)
        game.add_user(user1)
        user2 = create(:user)
        game.add_user(user2)
        game.users.should include(user1,user2)
        game.participants_count == 2
        game.users.count.should == 2
      end

      it "must start the game if there are 2 users" do
        game = create(:challenge_game)
        game.add_user(create(:user))
        game.add_user(create(:user))
        ChallengeGame.find(game.id).should be_started
      end

      it "wont start the game if there is 1 user" do
        game = create(:challenge_game)
        game.add_user(create(:user))
        ChallengeGame.find(game.id).should_not be_started
      end

    end

  end

  context "Class Methods" do

    describe "find_for_user" do

      before :each do
        @user = stub_model(User)
        @user.stub!(:active_challenge_game).and_return(nil)
        @challenge_game = stub_model(ChallengeGame)
      end

      it "must look for active games on user" do
        @user.should_receive(:active_challenge_game).and_return(nil)
        ChallengeGame.find_for_user(@user)
      end

      it "must find active challenge game already part" do
        @user.stub!(:active_challenge_game).and_return(@challenge_game)
        ChallengeGame.find_for_user(@user).should == @challenge_game
      end

      it "must search for a game waiting for a opponent" do
        ChallengeGame.should_receive(:waiting_for_opponent_game).with(@user).and_return(nil)
        ChallengeGame.find_for_user(@user)
      end

      it "must use game waiting for a opponent" do
        ChallengeGame.stub!(:waiting_for_opponent_game).and_return(@challenge_game)
        ChallengeGame.find_for_user(@user).should == @challenge_game
      end

      it "must create a new game" do
        ChallengeGame.should_receive(:create).with(anything)
        ChallengeGame.find_for_user(@user)
      end

      it "must return created game" do
        ChallengeGame.stub!(:create).and_return(@challenge_game)
        ChallengeGame.find_for_user(@user).should == @challenge_game
      end

    end

    describe "waiting_for_opponent_game" do

        before :each do
          @user = stub_model(User)
          @challenge_game = stub_model(ChallengeGame)
          ChallengeGame.stub_chain("incompleted.not_started.random_order.first").and_return(@challenge_game)
        end

        it "must return first incompleted and not started in random order" do
          ChallengeGame.waiting_for_opponent_game(@user).should == @challenge_game
        end

        it "must return nil if first incompleted and not started in random order is nil" do
          ChallengeGame.stub_chain("incompleted.not_started.random_order.first").and_return(nil)
          ChallengeGame.waiting_for_opponent_game(@user).should == nil
        end

        it "must add user to challenge game" do
          @challenge_game.should_receive(:add_user).with(@user)
          ChallengeGame.waiting_for_opponent_game(@user)
        end

    end

  end

end
