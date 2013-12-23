require 'twitter'

class TwitsController < ApplicationController
  before_action :init_clients

  def init_clients
    @twitter = CachedTwitter.new
  end




  def home
  end

  def for_user

    @max_id = params[:max_id]
    p @max_id
    @username = params[:username]
    @tweets = @twitter.tweets_for_username(@username, @max_id)

  end

  def followers

    @username = params[:username]
    @followers = @twitter.get_follower_ids(@username)

  end


  def follower_intersection

    @first = params[:first_user]
    @second = params[:second_user]

    @intersection = @twitter.calculate_intersection(@first, @second)
    p @intersection
  end

end
