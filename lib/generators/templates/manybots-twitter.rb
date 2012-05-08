# Configure Manybots Twitter OAuth client

ManybotsTwitter.setup do |config|
  
  # Twitter OAuth details TODO: Replace these
  config.consumer_key = "YOUR_CONSUMER_KEY"
  config.consumer_secret = "YOUR_CONSUMER_SECRET"
  config.oauth_token = "YOUR_OAUTH_TOKEN"
  config.oauth_token_secret = "YOUR_OAUTH_TOKEN_SECRET"
  
  # App nickname
  config.nickname = 'manybots-twitter'
end

app = ClientApplication.find_or_initialize_by_nickname ManybotsTwitter.nickname
if app.new_record?
  app.app_type = "Observer"
  app.name = "Twitter Observer"
  app.description = "Import your tweet activity from Twitter"
  app.url = ManybotsServer.url + '/manybots-twitter'
  app.app_icon_url = ManybotsServer.url + "/assets/manybots-instagram/icon.png"
  app.developer_name = "Manybots"
  app.developer_url = "https://www.manybots.com"
  app.category = "Social"
  app.is_public = true
  app.save
end
ManybotsTwitter.app = app
