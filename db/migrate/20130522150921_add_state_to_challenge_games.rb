class AddStateToChallengeGames < ActiveRecord::Migration
  def change
    add_column :challenge_games, :state, :string
  end
end
