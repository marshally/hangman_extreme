class ChallengeGameEventsController < ApplicationController
  include ActionController::Live

  before_filter :login_required

  def index
    response.headers['Content-Type'] = 'text/event-stream'
    Redis.new(uri: "redis://127.0.0.1:6379/8").subscribe("challenge_game_#{params[:challenge_game_id]}") do |on|
      on.message do |channel, msg|
        response.stream.write(sse(*JSON.parse(msg)))
      end
    end
  rescue IOError
    Rails.logger.info "Client Disconnected"
  ensure
    response.stream.close
  end

  private

  def sse(object, options = {})
    (options.map{|k,v| "#{k}: #{v}" } << "data: #{JSON.dump object}").join("\n") + "\n\n"
  end

end
