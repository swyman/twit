class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def init_clients

    @redis = Redis.new

    # already have this username in redis

    bearer_token = @redis.get(:app_bearer_token)
    p "token from redis: #{bearer_token}"

    @client = Twitter::REST::Client.new do |args|
      args.consumer_key = 'qSWtaqBe0yHBPY3mrCJDA'
      args.consumer_secret     = 'JdTf2X3dWUyNRIXorl3vdg4NxC58UCqwSfx1XCG1CuM'
      args.bearer_token = bearer_token unless bearer_token.nil?
    end

    if bearer_token.nil?
      @redis.set(:app_bearer_token, @client.token, ex: 180)
    end
  end
end
