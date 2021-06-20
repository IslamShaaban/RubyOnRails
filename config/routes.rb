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
end