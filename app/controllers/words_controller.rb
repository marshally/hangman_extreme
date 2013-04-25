class WordsController < ApplicationController
  before_filter :login_required
  #caches_action :define, expires_in: 7.days, :cache_path => proc{ {provider: current_user.provider} }

  def define
    @definition = Dictionary.define(params[:word])
  end

end
