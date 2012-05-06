Rails.application.routes.draw do

  mount ManybotsInstagram::Engine => "/manybots-twitter"
end
