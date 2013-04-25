HangmanLeague::Application.routes.draw do
  get "purchase_transactions", to: 'purchase_transactions#index', as: 'purchases'
  get "purchase_transactions/new", as: 'new_purchase'
  get "purchase_transactions/create", to: 'purchase_transactions#create', as: 'create_purchase'
  get "Transaction/PaymentRequest", to: 'purchase_transactions#simulate_purchase', as: 'mxit_purchase'
  get "explain/:action", as: 'explain', controller: 'explain'
  get "airtime_vouchers", to: 'airtime_vouchers#index', as: 'airtime_vouchers'

  resources :games, :except => [:edit, :update, :destroy] do
    collection do
      get 'play', action: "play"
    end
    get 'page/:page', :action => :index, :on => :collection
    member do
      get 'show_clue', action: "show_clue", as: 'show_clue'
      post 'show_clue', action: "reveal_clue"
      get "letter/:letter", action: 'play_letter', as: 'play_letter'
    end
  end
  resources :users, :except => [:create, :new, :destroy] do
    collection do
      get 'stats', action: "stats"
      get 'my_rank', action: "show"
      get 'mxit_oauth', action: 'mxit_oauth', as: 'mxit_oauth'
      get 'profile', action: 'profile', as: 'profile'
    end
  end
  resources :feedback, :except => [:show, :edit, :update, :destroy]
  resources :winners, :except => [:edit, :update, :create, :new, :destroy]
  resources :redeem_winnings, :except => [:edit, :update, :destroy]

  get '/define/:word', to: 'words#define', as: 'define_word'
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/:provider/failure', to: 'sessions#failure'
  post '/auth/:provider/callback', to: 'sessions#create'
  post '/auth/:provider/failure', to: 'sessions#failure'
  get '/auth/failure', to: 'sessions#failure'
  get '/authorize', to: 'users#mxit_authorise', as: 'mxit_authorise'
  get '/about', to: 'explain#about', as: 'about'
  get '/terms', to: 'explain#terms', as: 'terms'
  get '/privacy', to: 'explain#privacy', as: 'privacy'
  get '/logout', to: 'sessions#destroy', as: 'logout'

  root :to => 'games#index'
end
