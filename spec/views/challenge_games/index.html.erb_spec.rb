require 'spec_helper'

describe "challenge_games/index.html.erb" do

  it "must have a view rank link on the menu" do
    view.should_receive(:menu_item).with(anything,new_challenge_game_path,id: 'find_opponent')
    render
  end

end
