Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  # get 'students/show'
  # get 'students/pending_verification'
  devise_for :users, controllers: { registrations: "users/registrations" }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  resources :students, only: [:show] do
    collection do
      get :pending_verification # If not verified, show message
      # post :import # Bulk import via CSV
      # get :export # Export student details
    end
  end
  # Defines the root path route ("/")
  root "students#show"
  get "dashboard", to: "students#show", as: :student_dashboard
end
