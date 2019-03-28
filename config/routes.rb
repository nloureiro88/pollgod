Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'

  get :dash, to: "profiles#dash"
  get :ftoggle, to: "profiles#filter_toggle", as: :ftoggle
  get :filters, to: "profiles#filters", as: :filters

  resources :polls, except: [:edit, :update] do
    member do
      post :answer, to: "polls#add_answer"
      get :toggle, to: "polls#toggle"
      get :result, to: "polls#result"
      get :share, to: "polls#share"
      get :report, to: "polls#report"
    end

    collection do
      get :manage, to: "polls#manage", as: :manage
      get :answered, to: "polls#answered", as: :answered
      get :sponsored, to: "polls#sponsored", as: :sponsored
      get :fresh, to: "polls#fresh", as: :fresh
      get :loved, to: "polls#loved", as: :loved
      get :funny, to: "polls#funny", as: :funny
      get :interesting, to: "polls#interesting", as: :interesting
    end
  end

end
