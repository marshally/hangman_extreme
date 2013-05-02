class ChallengeGameParticipant < ActiveRecord::Base
  attr_accessible :user, :challenge_game
  validates :user_id, presence: true
  validates_uniqueness_of :user_id, scope: :challenge_game_id
  belongs_to :user
  belongs_to :challenge_game, counter_cache: 'participants_count'

  def to_s
    "<ChallengeGameParticipant user_id:#{user_id} challenge_game_id:#{challenge_game_id}>"
  end
end
