class ChallengeGameObserver < ActiveRecord::Observer

  def after_save(game)
    publish("challenge_game_#{game.id}",
            ([game.attributes.merge(word: nil),
              {event: 'updated'}]).to_json)
  end

  private

  def publish(*args)
    redis_connection.publish(*args)
  end

  def redis_connection
    self.class.redis_connection
  end

  def self.redis_connection
    @@_connection ||= Redis.new(uri: ENV['REDIS_URL'])
  end

end
