module ManybotsTwitter
  class TwitterController < ApplicationController
    require 'twitter'
    
    before_filter :authenticate_user!
    
    def index
      @tweets = current_user.oauth_accounts.where(:client_application_id => current_app.id)
      @schedules = load_schedules
    end
    
    def new
      configure_twitter
      redirect_to Twitter.authorize_url(:redirect_uri => twitter_callback_url)
    end
    
    def callback
      configure_twitter
      response = Twitter.get_access_token(params[:code], :redirect_uri => twitter_callback_url)
      token = response.access_token
      
      client = Twitter.client(:access_token => token)
      twitter_user = client.user
      
      twitter = current_user.oauth_accounts.find_or_create_by_client_application_id_and_remote_account_id(current_app.id, twitter_user.id)
      twitter.payload[:username] = twitter_user.username
      twitter.token = token
      twitter.save
      
      redirect_to root_path, :notice => "Twitter account '#{twitter_user.username}' registered."
    end
    
    def toggle
      twitter = current_user.oauth_accounts.find(params[:id])
      load_schedule(twitter)
      message = 'Please try again.'
      if @schedule
        ManybotsServer.queue.remove_schedule @schedule_name
        twitter.status = 'off'
        message = 'Stoped importing.'
      else 
        twitter.status = 'on'
        message = 'Started importing.'        
            
        ManybotsServer.queue.add_schedule @schedule_name, {
          :every => '2h',
          :class => "TwitterWorker",
          :queue => "observers",
          :args => twitter.id,
          :description => "Import pictures from Twitter for OauthAccount ##{twitter.id}"
        }
      
        ManybotsServer.queue.enqueue(TwitterWorker, twitter.id)
      end
      
      twitter.save
      
      redirect_to root_path, :notice => message
    end
    
    
    def destroy
      twitter = current_user.oauth_accounts.find(params[:id])
      load_schedule(twitter)
      ManybotsServer.queue.remove_schedule @schedule_name if @schedule
      twitter.destroy
      redirect_to root_path, notice: 'Account deleted.'
    end
    
  private
    def configure_twitter
      Twitter.configure do |config|
        config.consumer_key = ManybotsTwitter.consumer_key
        config.consumer_secret = ManybotsTwitter.consumer_secret
      end
    end
    
    def twitter_callback_url
      "#{ManybotsTwitter.app.url}/twitter/callback"
    end
    
    def current_app
      @manybots_twitter_app ||= ManybotsTwitter.app
    end
        
    def load_schedules
      ManybotsServer.queue.get_schedules
    end
    
    def load_schedule(oauth_account)
      schedules = load_schedules
      @schedule_name = "import_manybots_twitter_#{oauth_account.id}"
      @schedule = schedules.keys.include?(@schedule_name) rescue(false)
    end
    
    
  end
end
