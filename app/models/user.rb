class User < ActiveRecord::Base
  attr_accessible :name, :provider, :uid, :credits, :prize_points
  attr_accessible :real_name, :mobile_number, as: 'user'
  RANKING_FIELDS = Winner::WINNING_PERIODS.product(Winner::WINNING_REASONS - %w(random)).map{|x,y| "#{x}_#{y}"}

  has_many :games, :order => 'id ASC'
  has_many :winners
  has_many :redeem_winnings
  has_many :airtime_vouchers
  has_many :feedback
  has_many :challenge_game_participants
  has_many :challenge_games, through: :challenge_game_participants

  validates :provider, :uid, presence: true
  validates_uniqueness_of :uid, :scope => :provider

  scope :top_scorers, lambda{ |field| order("#{field} DESC") }
  scope :mxit, where(provider: 'mxit')
  scope :facebook, where(provider: 'facebook')
  scope :non_mxit, where('provider <> ?','mxit')
  scope :active_last_hour, lambda{ where('updated_at >= ?',1.hour.ago) }
  scope :active, lambda{ where('updated_at >= ?',7.days.ago) }
  scope :last_day, lambda{ where('created_at >= ?',1.day.ago) }
  scope :random_order, order(connection.instance_values["config"][:adapter].include?("mysql") ? 'RAND()' : 'RANDOM()')

  def self.active_mxit
    active.mxit
  end

  def self.active_mxit_today
    last_day.mxit
  end

  def self.active_non_mxit
    active.non_mxit
  end

  def self.active_non_mxit_today
    last_day.non_mxit
  end

  def self.find_or_create_from_auth_hash(auth_hash)
    auth_hash.stringify_keys!
    logger.debug "Auth Login Attempt with: #{auth_hash.to_s}"
    return nil if auth_hash['uid'].blank? || auth_hash['provider'].blank?
    user = find_or_create_by_uid_and_provider(auth_hash['uid'],auth_hash['provider'])
    user.set_user_info(auth_hash['info'])
    return user
  end

  def self.find_facebook_user_by_uid(uid)
    facebook.find_by_uid(uid)
  end

  def self.find_mxit_user(i)
    mxit.find_by_uid(i)
  end

  def self.find_facebook_user(i)
    facebook.find_by_uid(i)
  end

  def active_challenge_game
    challenge_games.incompleted.first
  end

  def set_user_info(info)
    if info
      info.stringify_keys!
      self.name = info['name']
      self.login = info['login']
      self.email = info['email'] if email.blank?
      save
    end
  end

  def calculate_daily_rating
    calculate_rating(games.today.first(12))
  end

  def calculate_weekly_rating
    calculate_rating(games.this_week.first(75))
  end

  def update_ratings
    update_daily_scores
    update_weekly_scores
  end

  def update_daily_scores
    self.daily_rating = calculate_daily_rating
    save
  end

  def update_weekly_scores
    self.weekly_rating = calculate_weekly_rating
    save
  end

  def rank(field,user_scope = User)
    user_scope.where("#{field} > ?", send(field)).count + 1
  end

  def utma(update_tracking = false)
    google_tracking.utma(update_tracking)
  end

  def google_tracking
    @google_tracking ||= GoogleTracking.find_or_create_by_user_id(id)
  end

  def send_message(msg)
    User.send_message(msg,[self]) if provider == 'mxit'
  end

  def registered_on_mxit_money?(connection = MxitMoneyApi.connect(ENV['MXIT_MONEY_API_KEY']))
    begin
      if connection
        result = connection.user_info(:id => uid)
        result[:is_registered]
      end
    rescue Exception => e
      Rails.logger.error(e.message)
      Airbrake.notify_or_ignore(
        e,
        :parameters    => {:user => self},
        :cgi_data      => ENV
      )
      false
    end
  end

  def not_registered_on_mxit_money?
    !registered_on_mxit_money?
  end

  def self.send_message(msg, users = User.mxit)
    UserSendMessage.new(msg,users).send_all
  end

  def self.purge_tracking!
    User.where('updated_at < ?',20.days.ago).each{|u| u.google_tracking.delete }.size
  end

  def self.new_day_set_scores!(force_week = false)
    User.update_all(daily_wins: 0, daily_rating: 0, daily_streak: 0, current_daily_streak: 0)
    if Date.current == Date.current.beginning_of_week || force_week
      User.update_all(weekly_wins: 0, weekly_rating: 0, weekly_streak: 0, current_weekly_streak: 0)
    end
  end

  def self.scoring_fields
    RANKING_FIELDS.clone
  end

  def increment_streak
    increment(:current_daily_streak)
    self.daily_streak = current_daily_streak if (current_daily_streak > daily_streak)
    increment(:current_weekly_streak)
    self.weekly_streak = current_weekly_streak if (current_weekly_streak > weekly_streak)
  end

  def increment_wins
    increment(:daily_wins)
    increment(:weekly_wins)
  end
  
  def current_game
    games.incompleted.active_first.today.first
  end

  def reset_streak
    self.current_daily_streak = 0
    self.current_weekly_streak = 0
  end

  def to_s
    "<User id:#{id} uid:#{uid} provider:#{provider}>"
  end

  def inspect
    to_s
  end

  def daily_wins_required_for_random
    [Winner.daily_random_games_required - daily_wins,0].max
  end

  def weekly_wins_required_for_random
    [Winner.weekly_random_games_required - weekly_wins,0].max
  end

  def mxit?
    provider == "mxit"
  end

  def facebook?
    provider == "facebook"
  end

  def guest?
    provider == "guest"
  end

  private

  def calculate_rating(scope)
    scope.inject(0){|sum,game| sum += game.score.to_i }
  end

end
