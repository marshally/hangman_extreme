require 'spec_helper'
require 'cancan/matchers'

describe Ability do

  context "User" do

    before :each do
      @user = create(:user)
      @ability = Ability.new(@user)
    end

    context "Games" do

      it "must be able to view games" do
        @ability.should be_able_to(:read, Game)
      end

      it "wont be able to read other users games" do
        game = create(:game, user: create(:user))
        @ability.should_not be_able_to(:read, game)
      end

      it "must be able to read own users games" do
        game = create(:game, user: @user)
        @ability.should be_able_to(:read, game)
      end

      it "must be able to create games" do
        @ability.should be_able_to(:create, Game)
      end

      it "wont be able to play letters on other users games" do
        game = create(:game, user: create(:user))
        @ability.should_not be_able_to(:play_letter, game)
      end

      it "must be able to play letters on own users games" do
        game = create(:game, user: @user)
        @ability.should be_able_to(:play_letter, game)
      end

    end

    context "ChallengeGames" do

      it "must be able to view games" do
        @ability.should be_able_to(:read, ChallengeGame)
      end

      it "wont be able to read other users games" do
        game = create(:challenge_game,
                      participants: [build(:challenge_game_participant),
                                     build(:challenge_game_participant)])
        @ability.should_not be_able_to(:read, game)
      end

      it "must be able to read own users games" do
        game = create(:challenge_game,
                      participants: [build(:challenge_game_participant, user: @user),
                                     build(:challenge_game_participant)])
        @ability.should be_able_to(:read, game)
      end

      it "must be able to create games" do
        @ability.should be_able_to(:create, ChallengeGame)
      end

      it "wont be able to play letters on other users games" do
        game = create(:challenge_game, started: true,
                      participants: [build(:challenge_game_participant),
                                     build(:challenge_game_participant)])
        @ability.should_not be_able_to(:play_letter, game)
      end

      it "must be able to play letters on own users games when turn" do
        participant = build(:challenge_game_participant, user: @user)
        game = create(:challenge_game, started: true,
                      participants: [participant,
                                     build(:challenge_game_participant)])
        game.update_attribute(:active_participant,participant)
        @ability.should be_able_to(:play_letter, game)
      end

      it "wont be able to play letters on own users games when not turn" do
        participant = build(:challenge_game_participant)
        game = create(:challenge_game, started: true,
                      participants: [participant,
                                     build(:challenge_game_participant, user: @user)])
        game.update_attribute(:active_participant,participant)
        @ability.should_not be_able_to(:play_letter, game)
      end

      it "wont be able to play letters on own games not started" do
        participant = build(:challenge_game_participant, user: @user)
        game = create(:challenge_game, started: false,
                      participants: [participant])
        game.update_attribute(:active_participant,participant)
        @ability.should_not be_able_to(:play_letter, game)
      end

    end

    context "Feedback" do

      it "must be able to view" do
        @ability.should be_able_to(:read, Feedback)
      end

      it "wont be able to read other users" do
        game = create(:feedback, user: create(:user))
        @ability.should_not be_able_to(:read, game)
      end

      it "must be able to read own" do
        game = create(:feedback, user: @user)
        @ability.should be_able_to(:read, game)
      end

      it "must be able to create" do
        @ability.should be_able_to(:create, Feedback)
      end

    end

    context "Users" do

      it "must be able to read users" do
        @ability.should be_able_to(:read, User)
      end

      it "must be able update self" do
        @ability.should be_able_to(:update, @user)
      end

      it "wont be able update other users" do
        user = create(:user)
        @ability.should_not be_able_to(:update, user)
      end

    end

    context "Winners" do

      it "must be able to read winners" do
        @ability.should be_able_to(:read, Winner)
      end

    end

    context "Purchase Transactions" do

      it "must be able to view purchase transactions" do
        @ability.should be_able_to(:read, PurchaseTransaction)
      end

      it "wont be able to read other users purchase_transactions" do
        trans = create(:purchase_transaction, user: create(:user))
        @ability.should_not be_able_to(:read, trans)
      end

      it "must be able to read own purchase_transactions" do
        trans = create(:purchase_transaction, user: @user)
        @ability.should be_able_to(:read, trans)
      end

      it "must be able to create purchase_transactions" do
        @ability.should be_able_to(:create, PurchaseTransaction)
      end

    end

    context "Redeem Winnings" do

      it "must be able to view redeem_winning" do
        @ability.should be_able_to(:read, RedeemWinning)
      end

      it "wont be able to read other users redeem_winnings" do
        trans = create(:redeem_winning, user: create(:user, prize_points: 2))
        @ability.should_not be_able_to(:read, trans)
      end

      it "must be able to read own redeem_winnings" do
        @user.increment!(:prize_points)
        trans = create(:redeem_winning, user: @user)
        @ability.should be_able_to(:read, trans)
      end

      it "must be able to create redeem_winning" do
        @ability.should be_able_to(:create, RedeemWinning)
      end

    end

    context "Airtime Vouchers" do

      it "must be able to read airtime vouchers" do
        @ability.should be_able_to(:read, AirtimeVoucher)
      end

      it "wont be able to read other users airtime vouchers" do
        airtime_voucher = create(:airtime_voucher, user: create(:user))
        @ability.should_not be_able_to(:read, airtime_voucher)
      end

      it "must be able to read own airtime vouchers" do
        airtime_voucher = create(:airtime_voucher, user: @user)
        @ability.should be_able_to(:read, airtime_voucher)
      end

    end

  end

  context "Guest" do

    before :each do
      @user = create(:user, provider: 'guest')
      @ability = Ability.new(@user)
    end

    context "Games" do

      it "must be able to view games" do
        @ability.should be_able_to(:read, Game)
      end

      it "wont be able to read other users games" do
        game = create(:game, user: create(:user))
        @ability.should_not be_able_to(:read, game)
      end

      it "must be able to read own users games" do
        game = create(:game, user: @user)
        @ability.should be_able_to(:read, game)
      end

      it "wont be able to create games" do
        @ability.should_not be_able_to(:create, Game)
      end

      it "wont be able to play letters on other users games" do
        game = create(:game, user: create(:user))
        @ability.should_not be_able_to(:play_letter, game)
      end

      it "must be able to play letters on own users games" do
        game = create(:game, user: @user)
        @ability.should be_able_to(:play_letter, game)
      end

    end

    context "ChallengeGames" do

      it "must be able to view games" do
        @ability.should be_able_to(:read, ChallengeGame)
      end

      it "wont be able to read other users games" do
        game = create(:challenge_game,
                      participants: [build(:challenge_game_participant),
                                     build(:challenge_game_participant)])
        @ability.should_not be_able_to(:read, game)
      end

      it "must be able to read own users games" do
        game = create(:challenge_game,
                      participants: [build(:challenge_game_participant, user: @user),
                                     build(:challenge_game_participant)])
        @ability.should be_able_to(:read, game)
      end

      it "wont be able to create games" do
        @ability.should_not be_able_to(:create, ChallengeGame)
      end

      it "wont be able to play letters on other users games" do
        game = create(:challenge_game,
                      participants: [build(:challenge_game_participant),
                                     build(:challenge_game_participant)])
        @ability.should_not be_able_to(:play_letter, game)
      end

      it "must be able to play letters on own users games when turn" do
        participant = build(:challenge_game_participant, user: @user)
        game = create(:challenge_game,
                      participants: [participant,
                                     build(:challenge_game_participant)])
        game.update_attribute(:active_participant,participant)
        @ability.should be_able_to(:play_letter, game)
      end

      it "wont be able to play letters on own users games when not turn" do
        participant = build(:challenge_game_participant)
        game = create(:challenge_game,
                      participants: [participant,
                                     build(:challenge_game_participant, user: @user)])
        game.update_attribute(:active_participant,participant)
        @ability.should_not be_able_to(:play_letter, game)
      end

    end

    context "Feedback" do

      it "must be able to view" do
        @ability.should be_able_to(:read, Feedback)
      end

      it "wont be able to read other users" do
        game = create(:feedback, user: create(:user))
        @ability.should_not be_able_to(:read, game)
      end

      it "must be able to read own" do
        game = create(:feedback, user: @user)
        @ability.should be_able_to(:read, game)
      end

      it "wont be able to create" do
        @ability.should_not be_able_to(:create, Feedback)
      end

    end

    context "Users" do

      it "must be able to read users" do
        @ability.should be_able_to(:read, User)
      end

      it "must be able update self" do
        @ability.should be_able_to(:update, @user)
      end

      it "wont be able update other users" do
        user = create(:user)
        @ability.should_not be_able_to(:update, user)
      end

    end

    context "Winners" do

      it "must be able to read winners" do
        @ability.should be_able_to(:read, Winner)
      end

    end

    context "Purchase Transactions" do

      it "must be able to view purchase transactions" do
        @ability.should be_able_to(:read, PurchaseTransaction)
      end

      it "wont be able to read other users purchase_transactions" do
        trans = create(:purchase_transaction, user: create(:user))
        @ability.should_not be_able_to(:read, trans)
      end

      it "must be able to read own purchase_transactions" do
        trans = create(:purchase_transaction, user: @user)
        @ability.should be_able_to(:read, trans)
      end

      it "wont be able to create purchase_transactions" do
        @ability.should_not be_able_to(:create, PurchaseTransaction)
      end

    end

    context "Redeem Winnings" do

      it "must be able to view redeem_winning" do
        @ability.should be_able_to(:read, RedeemWinning)
      end

      it "wont be able to read other users redeem_winnings" do
        trans = create(:redeem_winning, user: create(:user, prize_points: 2))
        @ability.should_not be_able_to(:read, trans)
      end

      it "must be able to read own redeem_winnings" do
        @user.increment!(:prize_points)
        trans = create(:redeem_winning, user: @user)
        @ability.should be_able_to(:read, trans)
      end

      it "wont be able to create redeem_winning" do
        @ability.should_not be_able_to(:create, RedeemWinning)
      end

    end

    context "Airtime Vouchers" do

      it "must be able to read airtime vouchers" do
        @ability.should be_able_to(:read, AirtimeVoucher)
      end

      it "wont be able to read other users airtime vouchers" do
        airtime_voucher = create(:airtime_voucher, user: create(:user))
        @ability.should_not be_able_to(:read, airtime_voucher)
      end

      it "must be able to read own airtime vouchers" do
        airtime_voucher = create(:airtime_voucher, user: @user)
        @ability.should be_able_to(:read, airtime_voucher)
      end

    end

  end

end