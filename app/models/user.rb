class User < ActiveRecord::Base
  validates :twitter, presence: true

end
