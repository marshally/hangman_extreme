class AddActiveToChallengeGameParticipants < ActiveRecord::Migration
  def change
    add_column :challenge_game_participants, :active, :boolean, default: false, null: false
  end
end
