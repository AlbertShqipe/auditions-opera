Rails.application.routes.draw do
  get 'dashboard', to: 'dashboard#index'
  get 'dashboard/data', to: 'dashboard#data'
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :audition_applications do
    member do
      patch :update_status
      patch :update_ethnicity
      get :confirm_attendance
      patch :update_attendance
    end
    resources :votes, only: [:create]
  end
  # Defines the root path route ("/")
  # root "posts#index"
end
