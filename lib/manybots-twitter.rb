require "manybots-twitter/engine"

module ManybotsTwitter
  # Twitter App Id for OAuth2
  mattr_accessor :twitter_app_id
  @@twitter_app_id = nil

  # Twitter App Secret for OAuth2
  mattr_accessor :twitter_app_secret
  @@twitter_app_secret = nil
  
  mattr_accessor :app
  @@app = nil
  
  mattr_accessor :nickname
  @@nickname = nil
  
  
  def self.setup
    yield self
  end
end