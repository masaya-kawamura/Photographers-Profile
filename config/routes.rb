Rails.application.routes.draw do

  root to: 'homes#top'
  get 'mypage' => 'users#mypage'
  resources :users, only: [:edit, :update, :destroy] do
    member do
      get :following, :follower
    end
    collection do
      get :withdrawal_confirmation
    end
  end
  resources :relationships, only: [:create, :destroy]
  resources :photographers do
    member do
      post :public_status_switching
    end
  end
  resources :photos do
    resource :favorites, only: [:create, :destroy]
    resources :comments, only: [:create, :destroy]
    resources :rates,    onry: [:create, :destroy]
    collection do
      get :ranking_index
    end
  end
  resources :chats, only: [:show, :create, :destroy]

  get 'search' => "searches#search"
  get "/genres/:id" => 'genres#index', as: 'genre'

  #===== deviseルーティング設定 ======
  devise_for :users,
             path: '',
             path_names: {
               sign_up:      '',
               sign_in:      'login',
               sign_out:     'logout',
               registration: 'signup',
             },
             controllers: {
               registrations: "users/registrations",
               passwords:     "users/passwords",
               sessions:      "users/sessions",
               confirmations: "users/confirmations",
               unlocks:       "users/unlocks",
             }
  devise_scope :user do
    post 'guest_sign_in' , :to => "users/sessions#guest_sign_in"
  end
end
