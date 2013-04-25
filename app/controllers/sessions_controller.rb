class SessionsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def create
    self.current_user = User.find_or_create_from_auth_hash(auth_hash)
    redirect_to '/'
  end

  def destroy
    self.current_user = nil
    redirect_to '/'
  end

  def failure
    redirect_to '/', alert: params[:message]
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

end

