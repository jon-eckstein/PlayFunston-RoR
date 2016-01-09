Playfunston::Application.routes.draw do
  get "home/index"
  get 'observations/image' => 'observations#image' 
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".  
  resources :observations  
  # You can have the root of your site routed with "root"
  root 'home#index'
end
