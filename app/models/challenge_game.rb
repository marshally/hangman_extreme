class ChallengeGame < ActiveRecord::Base
  include Domain::PlayChallengeGame
  attr_accessible :word, :active_participant_id, :participants, :state
  validates :word, presence: true

  has_many :participants, class_name: 'ChallengeGameParticipant', counter_cache: 'participants_count'
  alias :players :participants
  has_many :users, through: :participants

  scope :completed, where(state: 'completed')
  scope :incompleted, where('state <> ? OR state IS NULL', 'completed')
  scope :started, where(state: 'started')
  scope :not_started, where('state <> ? OR state IS NULL', 'started')
  scope :waiting_for_opponent, where(state: 'waiting_for_opponent')
  scope :random_order, order(connection.instance_values["config"][:adapter].include?("mysql") ? 'RAND()' : 'RANDOM()')

  before_validation :choose_word

  def active_player
    players.active.first
  end

  def active_player=(v)
    active_player.try(:turn_done!)
    v.turn_start!
  end

  def self.find_for_user(user)
    user.active_challenge_game ||
      waiting_for_opponent_game(user) ||
      new_game_for_user(user)
  end

  def to_s
    "<ChallengeGame##{id} state:#{state}>"
  end

  protected

  def choose_word
    self.word ||= Dictionary.random_value
  end

  private

  def self.waiting_for_opponent_game(user)
    waiting_for_opponent.random_order.first.try(:add_player,user.challenge_game_participants.build)
  end

  def self.new_game_for_user(user)
    game = ChallengeGame.create!
    game.add_player(user.challenge_game_participants.build)
    game
  end

end
