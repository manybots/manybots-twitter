module ManybotsTwitter
  class TwitterController < ApplicationController
    require 'twitter'
    
    before_filter :authenticate_user!
    
    def index
      begin
        @twitter = get_twitter
        @account = @twitter.user_timeline.first.user
        @tweets = @twitter.home_timeline
      rescue
        @twitter = nil
      end
      #@tweets = current_user.oauth_accounts.where(:client_application_id => current_app.id)
      @schedules = load_schedules
    end
    
    def new
      configure_twitter
      @auth = Twitter::OAuth.new ManybotsTwitter.consumer_key, ManybotsTwitter.consumer_secret
      redirect_to Twitter.authorize_url(:redirect_uri => twitter_callback_url)
    end
    
    def request_tokens
      rtoken = @auth.request_token :oauth_callback => twitter_callback_url
      [rtoken.token, rtoken.secret]
    end
    
    #def auth(rtoken, rsecret, verifier)
    #  @auth.authorize_from_request(rtoken, rsecret, verifier)
    #  @user.access_token, @user.access_secret = @auth.access_token.token, @auth.access_token.secret
    #  @user.save
    #end
    
    def callback
      response = request_tokens()
      token = response.access_token
      
      twitter = current_user.oauth_accounts.find_or_create_by_client_application_id_and_remote_account_id(current_app.id, @account.id)
      twitter.payload[:username] = @account.screen_name
      twitter.token = token
      twitter.save
      
      redirect_to root_path, :notice => "Twitter account '#{@account.screen_name}' registered."
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
    
    #################################################################################################
    #################################################################################################
    #################################################################################################
    #Start new code from PedroMTavares
  
    
    def authorize_url
      @auth.request_token(:oauth_callback => @callback_url).authorize_url
    end
    
    def get_twitter
      twitter = current_user.oauth_accounts.find_by_client_application_id(current_app.id)
      
      @auth.authorize_from_access(twitter.token.access_token, twitter.token.access_secret)
      twitter = Twitter::Base.new @auth
      twitter.home_timeline(:count => 1)
      twitter
    end
    
    def signin
      begin
        session[:rtoken], session[:rsecret] = request_tokens
        redirect_to authorize_url
      rescue
        flash[:error] = 'Error while connecting with Twitter. Please try again.'
        redirect_to :action => :index
      end
    end
    
    #def auth
    #  begin
    #    auth(session[:rtoken], session[:rsecret], params[:oauth_verifier])
    #    flash[:notice] = "Successfully signed in with Twitter."
    ##  rescue
    #    flash[:error] = 'You were not authorized by Twitter!'
    #  end
    #  redirect_to :action => :index
    #end
    
    def tweet
      begin
        @twitter = get_twitter
        @twitter.update params[:tweet]
        flash[:notice] = "Tweet successfully sent!"
      rescue
        flash[:error] = "Error sending the tweet! Twitter might be unstable. Please try again."
      end
      redirect_to :action => :index
    end
    
    #End
    #################################################################################################
    #################################################################################################
    #################################################################################################
    
    
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
