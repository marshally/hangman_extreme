require 'spec_helper'

describe "games/index" do
  include ViewCapybaraRendered

  before(:each) do
    @games =
    assign(:games, [
      stub_model(Game, id: 100, done?: true, hangman_text: "hello", score: 100),
      stub_model(Game, id: 101, done?: false, hangman_text: "goodbye", score: 500)
    ])
    @current_user = stub_model(User, id: 50)
    view.stub!(:current_user).and_return(@current_user)
    view.stub!(:mxit_request?).and_return(true)
    view.stub!(:facebook_user?).and_return(false)
    view.stub!(:guest?).and_return(false)
    view.stub!(:menu_item)
  end

  it "renders a list of games" do
    render
    within("#game_100") do
      rendered.should have_content("hello")
      rendered.should have_content("100")
    end
    within("#game_101") do
      rendered.should have_content("goodbye")
      rendered.should have_content("500")
    end
  end

  it "renders a actions of games" do
    render
    within("#game_100") do
      rendered.should have_link("show_game_100", href: game_path(100))
    end
    within("#game_101") do
      rendered.should have_link("show_game_101", href: game_path(101))
    end
  end

  it "must have a view rank link on the menu" do
    view.should_receive(:menu_item).with(anything,user_path(50),id: 'view_rank')
    render
  end

  it "must have a view challenge link on the menu" do
    view.should_receive(:menu_item).with(anything,challenge_games_path,id: 'challenge')
    render
  end

  it "wont have a view rank link on the menu if guest" do
    view.stub!(:guest?).and_return(true)
    view.should_not_receive(:menu_item).with(anything,user_path(50),anything)
    render
  end

  it "should have a leaderboard link on menu" do
    view.should_receive(:menu_item).with(anything,users_path,id: 'leaderboard')
    render
  end

  it "must have a feedback link on the menu" do
    args = {response_type: 'code',
            host: "test.host",
            protocol: 'http',
            client_id: ENV['MXIT_CLIENT_ID'],
            redirect_uri: mxit_oauth_users_url(host: "test.host"),
            scope: "profile/public profile/private",
            state: "feedback"}
    view.should_receive(:menu_item).with(anything,mxit_authorise_url(args),id: 'feedback')
    render
  end

  it "must have a ordinary feedback link on the menu if not mxit request" do
    view.stub!(:mxit_request?).and_return(false)
    view.stub!(:mxit_request?).and_return(false)
    view.should_receive(:menu_item).with(anything,feedback_index_path,id: 'feedback')
    render
  end

  it "must have a authorise" do
    args = {response_type: 'code',
            host: "test.host",
            protocol: 'http',
            client_id: ENV['MXIT_CLIENT_ID'],
            redirect_uri: mxit_oauth_users_url(host: "test.host"),
            scope: "profile/public profile/private",
            state: "profile"}
    view.should_receive(:menu_item).with(anything,mxit_authorise_url(args),id: 'authorise')
    render
  end

  it "must have a ordinary authorise link on the menu if not mxit request" do
    view.stub!(:mxit_request?).and_return(false)
    view.should_receive(:menu_item).with(anything,profile_users_path,id: 'authorise')
    render
  end

  it "must have a buy more credits link" do
    view.should_receive(:menu_item).with(anything,purchases_path,id: 'buy_credits')
    render
  end

  it "must have a link to redeem winnings if user have prize points" do
    view.should_receive(:menu_item).with(anything,redeem_winnings_path,id: 'redeem')
    render
  end

end