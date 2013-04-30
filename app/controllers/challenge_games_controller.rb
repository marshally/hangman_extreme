class ChallengeGamesController < ApplicationController
  before_filter :check_credits, :only => ['new','create']
  load_and_authorize_resource

  def index
  end

  def new
    redirect_to(ChallengeGame.find_for_user(current_user))
  end

  def show
    @challenge_game = @challenge_game.decorate

    respond_to do |format|
      format.html
      format.js
    end
  end

  def play_letter

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
