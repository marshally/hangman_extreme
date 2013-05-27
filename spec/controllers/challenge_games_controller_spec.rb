require 'spec_helper'

describe ChallengeGamesController do

  before :each do
    @current_user = create(:user)
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    @ability.can(:manage, :all)
    controller.stub(:current_ability).and_return(@ability)
    controller.stub(:current_user).and_return(@current_user)
    controller.stub(:send_stats)
  end

  describe "GET index" do

    def do_get_index
      get :index
    end

    it "assigns all completed games as @games" do
      game = create(:challenge_game,
                    participants: [build(:challenge_game_participant, user: @current_user),
                                   build(:challenge_game_participant)])
      do_get_index
      assigns(:challenge_games).should eq([game])
    end

    it "renders successfully" do
      do_get_index
      response.should be_success
    end

  end

  describe "GET new" do

    before :each do
      @challenge_game = stub_model(ChallengeGame)
      ChallengeGame.stub!(:find_for_user).and_return(@challenge_game)
    end

    def do_get_new
      get :new
    end

    it "must find_for_user" do
      ChallengeGame.should_receive(:find_for_user).with(@current_user).and_return(@challenge_game)
      do_get_new
    end

    it "must be redirect_to the challenge_game" do
      do_get_new
      response.should redirect_to(@challenge_game)
    end

    it "redirects to purchase_transaction_path if no more credits" do
      @current_user.update_attribute(:credits,0)
      do_get_new
      response.should redirect_to(purchases_path)
      flash[:alert].should_not be_blank
    end

  end

end
