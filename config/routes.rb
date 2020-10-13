Rails.application.routes.draw do
  
  resources :videos
  root 'welcome#index'
 
  # root 'welcome#index'
  
  devise_for :users
 # get 'home/index'
end
