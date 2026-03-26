Rails.application.routes.draw do
  get "users/show"
  post "stripe/webhook", to: "stripe_webhooks#create"
  root "dashboard#index"
  get "dashboard", to: "dashboard#index", defaults: { format: :html }
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  post "activate_title", to: "users#activate_title"
  post "deactivate_title", to: "users#deactivate_title"

  # Classement
  resources :leaderboard, only: [ :index, :show ]

  # Gestion des utilisateurs
  resources :users, only: [ :index ]

  # Quêtes et progression
  resources :quests, only: [ :index, :show ]
  resources :user_quests, only: [ :update, :create, :destroy ]

  # Achats et paiements
  resources :purchases, only: [ :new, :create ] do
    collection do
      get "success"
      get "cancel"
    end
  end

  # Amis
  resources :friends, only: [ :index, :create, :destroy ] do
    collection do
      get :search
    end
    member do
      post :accept
      delete :reject
    end
  end
  resources :user_weekly_quests, only: [ :update ]


  get 'profil', to: 'users#show', as: :user_profile

  # Admin
  namespace :admin do
    resources :quests, except: [ :show ]
    resources :users, only: [ :index, :edit, :update ]
  end
end
