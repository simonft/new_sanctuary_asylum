Rails.application.routes.draw do
  devise_for :users, controllers: { invitations: "invitations"}
  
  devise_scope :user do
    authenticated do
      root :to => 'dashboard#index', as: :root
    end

    unauthenticated do
      root :to => 'devise/sessions#new', as: :unauthenticated_root
    end
  end

  get 'admin', to: 'admin/activities#index'
  get 'dashboard', to: 'dashboard#index'
  get 'pledge', to: 'home#pledge'

  resources :users, only: [:edit, :update]
  resources :friends, only: [:index, :show, :update] do
    resources :asylum_application_drafts, except: [:destroy]
  end
  resources :accompaniements
  resources :activities, only: [:index]

  namespace :admin do
  	resources :users
    resources :activities, except: [:destroy] do
      collection do
        get :last_month
      end
    end
    resources :friends do
      resources :activities, controller: 'friends/activities'
      resources :family_members
    end

    resources :judges, except: [:show, :destroy]
    resources :locations, except: [:show, :destroy]
    resources :lawyers, except: [:show, :destroy]

    resources :events do
      member do
        get :attendance
      end
      resources :friend_event_attendances, only: [:create, :destroy]
      resources :user_event_attendances, only: [:create, :destroy]
      resources :friend_event_attendances, only: [:create, :destroy]
    end
  end
end
