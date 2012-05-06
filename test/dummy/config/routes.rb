Rails.application.routes.draw do

  mount ManybotsTwitter::Engine => "/manybots-twitter"
end
