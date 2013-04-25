class ExplainController < ApplicationController
  #caches_action :payouts, :rating, :scoring_categories, :winning_random,
  #              :winning_streak, expires_in: 7.days, cache_path: proc{ {provider: current_user.try(:provider)} }

  before_filter :set_as_dialog, :only => [:rating, :winning_random, :winning_streak]

  protected

  def set_as_dialog
    @dialog = true
  end
end
