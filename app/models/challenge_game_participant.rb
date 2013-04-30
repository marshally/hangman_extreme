class ChallengeGameParticipant < ActiveRecord::Base
  attr_accessible :user
  validates :user_id, presence: true
  validates_uniqueness_of :user_id, scope: :challenge_game_id
  belongs_to :user
  belongs_to :challenge_game, counter_cache: 'participants_count'
end
