class CachedTwitter
  def initialize
    @redis = Redis.new

    # maybe save an api hit
    bearer_token = @redis.get(:app_bearer_token)
    p "token from redis: #{bearer_token}"

    # put secret stuff somewhere secret
    @client = Twitter::REST::Client.new do |args|
      args.consumer_key = 'qSWtaqBe0yHBPY3mrCJDA'
      args.consumer_secret     = 'JdTf2X3dWUyNRIXorl3vdg4NxC58UCqwSfx1XCG1CuM'
      args.bearer_token = bearer_token unless bearer_token.nil?
    end

    # save a future api hit
    if bearer_token.nil?
      @redis.set(:app_bearer_token, @client.token, ex: 180)
    end
  end



  def tweets_for_username(username)
    # if we have tweets in redis for this user, no request to twitter
    redis_user_key = self.redis_tweet_key_for_user(username)
    tweets = @redis.lrange(redis_user_key, 0, -1)
    if tweets.empty?

      # must request from twitter
      options = { :count => 10 }
      responses = @client.user_timeline(username, options)

      # all we're storing is text of each tweet
      tweets = responses.map { |item| item.text }

      # cache these tweets locally for some period of time
      @redis.lpush(redis_user_key, tweets)
      @redis.expire(redis_user_key, 60)
    end
    tweets
  end

  def get_follower_ids(user)

    followers = self.get_follower_ids_from_cache(user)
    puts "cache response: #{followers}"
    if followers.empty?
      self.populate_followers_from_remote(user)
      self.get_follower_ids_from_cache(user)
    else
      followers
    end

  end

  def populate_followers_from_remote(user)

    redis_key = self.redis_follower_key_for_user(user)
    followers = self.get_follower_ids_from_remote(user)

    @redis.sadd(redis_key, followers)
    @redis.expire(redis_key, 1200)

  end



  # rate limit issue: can only grab 75k ids per 15 minute period
  def get_follower_ids_from_remote(user, follower_ids = [], cursor_val = -1)
    p user
    cursor = @client.follower_ids(user, cursor: cursor_val, skip_status: 1, include_user_entities: false)
    follower_ids.concat(cursor.entries)
    if cursor.next == 0
      follower_ids
    else
      self.get_follower_ids_from_remote(user, follower_ids, cursor.next)
    end
  end



  def get_follower_ids_from_cache(user)
    cache_key = redis_follower_key_for_user(user)
    puts "cache key: #{cache_key}"
    @redis.smembers(cache_key)
  end

  def calculate_intersection(first_user, second_user)

    self.get_follower_ids(first_user)
    self.get_follower_ids(second_user)

    p 'here'
    first_key = self.redis_follower_key_for_user(first_user)
    second_key = self.redis_follower_key_for_user(second_user)
    intersect_ids = @redis.sinter(first_key, second_key)
    intersect_ids.map! { |id_str| id_str.to_i }
    p intersect_ids # [int, int, int]

    need_to_contact_twitter = intersect_ids.select do |id|
      !@redis.exists(self.redis_username_key_for_id(id))
    end

    self.add_username_cache_entries(need_to_contact_twitter)

    intersect_ids.map! { |id| self.redis_username_key_for_id(id) }
    @redis.mget(intersect_ids)
    #to_return = @client.users(intersect_ids, include_entities: false)
    #p to_return
    #to_return
  end

  def add_username_cache_entries(ids)
    ids.each_slice(100) do |chunk|
      users = @client.users(chunk, include_entities: false)
      hash_pairs = users.inject({}) do |result, user|
        result[self.redis_username_key_for_id(user.id)] = user.username
        result
      end
      @redis.mapped_mset(hash_pairs)
    end
  end







  def redis_tweet_key_for_user(user)
    "tweets:#{user}"
  end

  def redis_follower_key_for_user(user)
    "followers:#{user}"
  end

  def redis_username_key_for_id(id)
    "user_id:#{id}"
  end
end