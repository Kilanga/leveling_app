Rails.application.routes.draw do
  get "users/show"
  get "user_weekly_quests/update"
  root "dashboard#index"
  get "dashboard", to: "dashboard#index", defaults: { format: :html }
  devise_for :users

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
      get :search  # ✅ Ajoute la recherche d'amis
    end
    member do
      post :accept
      delete :reject
    end
  end
  resources :user_weekly_quests, only: [:update]


  get 'profil', to: 'users#show', as: :user_profile

  # Admin
  namespace :admin do
    resources :quests, except: [ :show ]
    resources :users, only: [ :index, :edit, :update ]
  end
end
