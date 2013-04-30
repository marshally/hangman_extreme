class GamesController < ApplicationController
  before_filter :login_required, :except => ['index']
  before_filter :check_credits, :only => ['new','create','show_clue','reveal_clue']
  load_and_authorize_resource except: 'play'

  def index
    @current_game = current_user.current_game
    @games = @games.completed.active_first.page(params[:page]).per(1)
  end

  def show

  end

  def play
    redirect_to(current_user.current_game || new_game_path)
  end

  def show_clue

  end

  def reveal_clue
    @game.reveal_clue
    play
  end

  def play_letter
    ranks = {}
    if @game.possible_last_guess?
      User.scoring_fields.each do |rank_by|
        ranks[rank_by] = current_user.rank(rank_by)
      end
    end
    @game.add_choice(params[:letter])
    @game.save
    if @game.completed?
      current_user.reload
      @notice ||= ""
      unless ranks.empty?
        User.scoring_fields.each do |rank_by|
          rank = current_user.rank(rank_by)
          @notice << "#{rank_by.gsub("_"," ")}: #{rank.ordinalize}. "  if rank < ranks[rank_by]
        end
      end
    end
    redirect_to @game, notice: @notice
  end

  def new

  end

  def create
    @game.user = current_user
    @game.select_random_word
    if @game.word == 'missing'
      e = Exception.new("Dictionary not loaded")
      ENV['AIRBRAKE_API_KEY'].present? ? notify_airbrake(e) : Rails.logger.error(e.message)
    end
    if @game.save
      current_user.decrement!(:credits)
      redirect_to @game, notice: 'Game was successfully created.'
    else
      redirect_to({action: 'index'}, alert: 'Failed to create new game.')
    end
  end

  protected

  def check_credits
    if current_user.credits > 0
      true
    else
      redirect_to purchases_path, alert: "No more credits points left"
      false
    end
  end

end
