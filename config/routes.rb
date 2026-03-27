Rails.application.routes.draw do
  post "stripe/webhook", to: "stripe_webhooks#create"
  root "dashboard#index"
  get "dashboard", to: "dashboard#index", defaults: { format: :html }
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  post "activate_title", to: "users#activate_title"
  post "deactivate_title", to: "users#deactivate_title"
  post "activate_avatar", to: "users#activate_avatar"
  resources :notifications, only: [ :index, :update ] do
    collection do
      patch :mark_all_read
    end
  end

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
      post "claim_weekly_challenge"
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
  resources :friend_challenges, only: [ :create ]
  resources :user_weekly_quests, only: [ :update ]

  get "profil/completer", to: "users#complete_profile", as: :complete_profile
  patch "profil/completer", to: "users#update_profile"
  patch "profil/pseudo", to: "users#update_pseudo", as: :update_pseudo

  get "profil", to: "users#show", as: :user_profile

  # Admin
  namespace :admin do
    resources :quests, except: [ :show ]
    resources :users, only: [ :index, :edit, :update ]
    resources :analytics, only: [ :index ]
  end
end
