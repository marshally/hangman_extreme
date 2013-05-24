class RemoveStartedAndCompletedFromChallengeGames < ActiveRecord::Migration
  def up
    remove_column :challenge_games, :completed
    remove_column :challenge_games, :started
  end

  def down
    add_column :challenge_games, :completed, :boolean
    add_column :challenge_games, :started, :boolean
  end
end
