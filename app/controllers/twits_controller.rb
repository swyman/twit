require 'twitter'

class TwitsController < ApplicationController
  before_action :init_clients

  def home
  end

  def for_user

    # if we have tweets in redis for this user, no request to twitter
    redis_user_key = self.redis_tweet_key_for_user(params[:username])
    @tweets = @redis.lrange(redis_user_key, 0, -1)
    if @tweets.empty?

      # must request from twitter
      options = { :count => 10 }
      responses = @client.user_timeline(params[:username], options)

      # all we're storing is text of each tweet
      @tweets = responses.map { |item| item.text }

      # cache these tweets locally for some period of time
      @redis.lpush(redis_user_key, @tweets)
      @redis.expire(redis_user_key, 60)
    end

  end

  def followers

    @username = params[:username]
    @followers = self.ensure_followers_cache(@username)

  end

  def ensure_followers_cache(user)

    followers = followers_from_cache(user)
    puts "cache response: #{followers}"
    if followers.empty?
      self.populate_followers_remote(user)
    else
      followers
    end

  end

  def populate_followers_remote(user)

    redis_key = self.redis_follower_key_for_user(user)
    cursor = @client.followers(user, skip_status: 1, include_user_entities: false)
    cursor.each do |thing|
      p thing
      p thing.name
      @redis.sadd(redis_key, thing.name)
    end
    @redis.expire(redis_key, 600)

  end

  def followers_from_cache(user)
    cache_key = redis_follower_key_for_user(user)
    puts "cache key: #{cache_key}"
    @redis.smembers(cache_key)
  end

  def follower_intersection(first_user, second_user)

  end

  def redis_tweet_key_for_user(user)
    "tweets:#{user}"
  end

  def redis_follower_key_for_user(user)
    "followers:#{user}"
  end
end
