Rails.application.routes.draw do
  scope "(:locale)", locale: /en|fr/ do
    get 'dashboard/data', to: 'dashboard#data', as: :dashboard_data
    get 'dashboard/rapport', to: 'dashboard#rapport', as: :dashboard_rapport
    get "dashboard/download_rapport", to: "dashboard#download_rapport", as: :download_rapport
    get '/help', to: 'pages#help', as: :help
    get '/invited_candidates', to: 'pages#invited_candidates', as: :invited_candidates
    resources :dashboard, only: [:index, :show]
    devise_for :users
    root to: "pages#home"
    get "final_step", to: "pages#final_step", as: :final_step

    if Rails.env.development?
      mount LetterOpenerWeb::Engine, at: "/letter_opener"
    end

    resources :audition_applications do
      member do
        patch :update_status
        patch :update_ethnicity
        get :confirm_attendance
        post :confirm_attendance_message
        patch :update_attendance
      end
      collection do
        post :send_results
      end
      resources :votes, only: [:create]
    end
  end
end
