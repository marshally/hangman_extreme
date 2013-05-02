class ChallengeGame < ActiveRecord::Base
  attr_accessible :word, :active_participant_id, :participants
  validates :word, presence: true

  has_one :active_participant, class_name: 'ChallengeGameParticipant'
  has_one :active_user, through: :active_participant, class_name: 'User', source: :user
  has_many :participants, class_name: 'ChallengeGameParticipant', counter_cache: 'participants_count'
  has_many :users, through: :participants

  scope :completed, where(completed: true)
  scope :incompleted, where('completed = ? OR completed IS NULL', false)
  scope :started, where(started: true)
  scope :not_started, where('started = ? OR started IS NULL', false)
  scope :random_order, order(connection.instance_values["config"][:adapter].include?("mysql") ? 'RAND()' : 'RANDOM()')

  before_validation :choose_word

  def self.find_for_user(user)
    user.active_challenge_game ||
      waiting_for_opponent_game(user) ||
      new_game_for_user(user)
  end

  def self.waiting_for_opponent_game(user)
    incompleted.not_started.random_order.first.try(:add_user,user)
  end

  def add_user(user)
    self.participants << user.challenge_game_participants.build
    start_game if !started? && self.participants(true).size > 1
    self
  end

  def to_s
    "<ChallengeGame id:#{id} completed:#{completed} started:#{started}>"
  end

  def add_choice(letter)
    self.choices ||= ""
    return if completed? || letter.to_s.size > 1
    letter.downcase!
    if letter =~ /\p{Lower}/
      next_participant unless word.include?(letter)
      self.choices += letter
    end
  end

  def next_participant
    self.active_participant = participants.where('id <> ?',active_participant.id).first
  end

  protected

  def choose_word
    self.word ||= Dictionary.random_value
  end

  private

  def start_game
    self.started = true
    save!
  end

  def self.new_game_for_user(user)
    game = ChallengeGame.create(participants: [user.challenge_game_participants.build])
    game.active_participant = game.participants.first
    game.save
    game
  end

end
