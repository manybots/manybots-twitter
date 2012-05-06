ManybotsTwitter::Engine.routes.draw do
  resources :twitter do
    collection do
      get 'callback'
    end
    member do 
      post 'toggle'
    end
  end
  
  root to: 'twitter#index'
end
