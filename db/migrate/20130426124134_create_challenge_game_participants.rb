class CreateChallengeGameParticipants < ActiveRecord::Migration
  def change
    create_table :challenge_game_participants do |t|
      t.belongs_to :user, index: true
      t.belongs_to :challenge_game, index: true

      t.timestamps
    end
  end
end
