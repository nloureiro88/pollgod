Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'

  get :dash, to: "profiles#dash"
  post :ftoggle, to: "profiles#filter_toggle", as: :ftoggle

  resources :polls, except: [:edit, :update] do
    member do
      post :answer, to: "polls#add_answer"
      post :toggle, to: "polls#toggle"
      get :result, to: "polls#result"
      get :share, to: "polls#share"
    end

    collection do
      get :manage, to: "polls#manage", as: :manage
      get :answered, to: "polls#answered", as: :answered
    end
  end

end
