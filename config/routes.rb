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
      get :mypolls, to: "polls#management", as: :my
      get :myanswers, to: "polls#show_answers", as: :answered
    end
  end

end
