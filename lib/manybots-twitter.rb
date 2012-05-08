require "manybots-twitter/engine"

module ManybotsTwitter
  # Twitter Consumer Key for OAuth2
  mattr_accessor :consumer_key
  @@consumer_key = nil

  # Twitter Consumer Secret for OAuth2
  mattr_accessor :consumer_secret
  @@consumer_secret = nil
  
  mattr_accessor :app
  @@app = nil
  
  mattr_accessor :nickname
  @@nickname = nil
  
  
  def self.setup
    yield self
  end
end