Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'

  as :user do
    get 'users', to: "profiles#dash", as: :user_root
  end

  get :dash, to: "profiles#dash"
  get :go_premium, to: "profiles#go_premium", as: :go_premium
  get :go_pro, to: "profiles#go_pro", as: :go_pro
  get :ftoggle, to: "profiles#filter_toggle", as: :ftoggle
  get :filters, to: "profiles#filters", as: :filters
  get :filterall, to: "profiles#filter_all", as: :filterall

  resources :polls, except: [:edit, :update] do
    member do
      post :answer, to: "polls#add_answer"
      get :toggle, to: "polls#toggle"
      post :result, to: "polls#result"
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
      get :friend, to: "polls#friend", as: :friend
    end
  end

  resources :friends, only: :index do
    get :add, to: "friends#add", as: :add
    get :remove, to: "friends#remove", as: :remove
  end
end
