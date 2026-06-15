Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :titles, only: [ :index, :show ] do
    member do
      get :writers
      get :directors
      get :cast
      get :principals
    end
  end

  resources :writers,    only: [ :show ]
  resources :directors,  only: [ :show ]
  resources :cast,       only: [ :show ]
  resources :principals, only: [ :show ]
end
