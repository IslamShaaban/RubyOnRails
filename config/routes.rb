Rails.  application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
  
  ###################Restful API Routes#################
  namespace :api do
    namespace :v1 do
      post "register", to: "users#register"
      post "login", to: "users#login"
      get "auto_login", to: "users#auto_login"
      delete "/my-posts", to: "posts#destroyAll"
      resources :posts do
        get "/tags", to: "tags#show"
        put "/tags", to: "tags#update"
        delete "/tags", to: "tags#destroy"
        resources :comments
        delete "my-comments", to: "comments#destroyAll"
      end
    end
  end
  ######################################################

  ####################### Users Routes #####################
  get 'register', to: 'users#register', as: 'register'
  post 'register', to: 'users#create', as: 'registeration'
  get 'login', to: 'users#login', as: 'login'
  post 'login', to: 'users#check', as: 'new_session'
  ##########################################################
  
  ###################### Posts and Comments Routes ########################
  resources :posts do
    resources :comments
  end
  #########################################################################

  match 'path', :to => 'errors#routing', :via => [:get, :post, :put, :delete, :patch, :head, :options]
end