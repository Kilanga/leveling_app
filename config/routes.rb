Rails.application.routes.draw do
  post "stripe/webhook", to: "stripe_webhooks#create"
  root "welcome#index"
  get "welcome", to: "welcome#index"
  get "terms", to: "pages#terms", as: :terms
  get "privacy", to: "pages#privacy", as: :privacy
  get "dashboard", to: "dashboard#index", defaults: { format: :html }
  post "dashboard/claim_daily_chest", to: "dashboard#claim_daily_chest", as: :claim_daily_chest
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  post "activate_title", to: "users#activate_title"
  post "deactivate_title", to: "users#deactivate_title"
  post "activate_avatar", to: "users#activate_avatar"
  post "activate_cosmetic", to: "users#activate_cosmetic"
  patch "update_profile_card_text", to: "users#update_profile_card_text"
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
  resources :factions, only: [] do
    member do
      post :join
    end
  end
  resources :daily_contracts, only: [] do
    member do
      post :accept
    end
  end
  resources :user_daily_contracts, only: [] do
    member do
      post :claim
    end
  end

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
