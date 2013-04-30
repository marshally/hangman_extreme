class CreateChallengeGames < ActiveRecord::Migration
  def change
    create_table :challenge_games do |t|
      t.string :word
      t.text :choices
      t.boolean :completed, default: false
      t.boolean :started, default: false
      t.integer :active_participant_id
      t.integer :participants_count

      t.timestamps
    end
  end
end
