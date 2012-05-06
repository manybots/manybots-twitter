# Configure Manybots Twitter OAuth client

ManybotsTwitter.setup do |config|
  # Twitter OAuth App Id
  config.twitter_app_id = '<replace me>'
  
  # Twitter OAuth App Secret
  config.twitter_app_secret = '<replace me>'
  
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
