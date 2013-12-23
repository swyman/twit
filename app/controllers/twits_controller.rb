require 'twitter'

class TwitsController < ApplicationController
  def home
  end

  def for_user
    @foo = params[:username]

    client = Twitter::REST::Client.new(:consumer_key => 'qSWtaqBe0yHBPY3mrCJDA', :consumer_secret => 'JdTf2X3dWUyNRIXorl3vdg4NxC58UCqwSfx1XCG1CuM', :access_token => '91212144-7rvR1Hp0JKbsCsSRkPstpu8TLy3PqeE7kBMYZu4D9', :access_token_secret => 'MlXvO36pRxo3TYxCNi0yGcAqBaDMDGI3eRJJNcLzW56y1')
    options = { :count => 5 }
    @stuff = client.user_timeline(@foo, options);


  end

  def followers
    @foo = params[:username]

    client = Twitter::REST::Client.new(:consumer_key => 'qSWtaqBe0yHBPY3mrCJDA', :consumer_secret => 'JdTf2X3dWUyNRIXorl3vdg4NxC58UCqwSfx1XCG1CuM', :access_token => '91212144-7rvR1Hp0JKbsCsSRkPstpu8TLy3PqeE7kBMYZu4D9', :access_token_secret => 'MlXvO36pRxo3TYxCNi0yGcAqBaDMDGI3eRJJNcLzW56y1')
    options = { :count => 5 }
    @stuff = client.followers(@foo, options);
  end
end
