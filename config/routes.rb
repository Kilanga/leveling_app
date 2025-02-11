Rails.application.routes.draw do
  get "leaderboard/index"
  get "purchases/new"
  get "purchases/create"
  get "user_quests/update"
  get "quests/index"
  get "quests/show"
  get "dashboard/index"

  root "dashboard#index"

  devise_for :users
  get "leaderboard", to: "leaderboard#index"
  resources :quests, only: [ :index, :show ]
  resources :user_quests, only: [ :update ]
  resources :purchases, only: [ :new, :create ] do
    collection do
      get "success"
      get "cancel"
    end
  end

  namespace :admin do
    get "users/index"
    get "users/edit"
    get "users/update"
    get "quests/index"
    get "quests/new"
    get "quests/create"
    get "quests/edit"
    get "quests/update"
    get "quests/destroy"
    resources :quests, except: [ :show ]
    resources :users, only: [ :index, :edit, :update ]
  end
end
