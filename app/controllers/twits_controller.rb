require 'twitter'

class TwitsController < ApplicationController
  before_action :init_clients

  def init_clients
    @twitter = CachedTwitter.new
  end




  def home
  end

  def for_user

    @username = params[:username]
    @tweets = @twitter.tweets_for_username(@username, params[:max_id])

  end

  def followers

    @username = params[:username]
    @followers = @twitter.get_follower_ids(@username)

  end


  def follower_intersection

    @first = params[:first_user]
    @second = params[:second_user]

    @intersection = @twitter.calculate_intersection(@first, @second)
  end

end
