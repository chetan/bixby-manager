Bixby::Application.routes.draw do

  # Default route
  root "inventory/hosts#index"

  # put 'users/password' => "users#reset_password"

  get  "/login"          => "sessions#new"
  post "/login/checkga"  => "sessions#update"
  post "/login"          => "sessions#create"
  post "/logout"         => "sessions#destroy"

  post "/users/password" => "passwords#create"
  put  "/users/password" => "passwords#update"

  # API Controller endpoint
  post '/api' => 'api#handle'


  ##############################################################################
  # RESTFUL ROUTES
  # (API CALLS)
  #
  # These routes are primarily used for CRUD style actions on resources

  namespace :rest, :module => "rest/models" do

    resources :agents do
      get "update_check_config" => "agents#update_check_config"
    end

    resources :check_templates do
      resources :items
    end

    resources :hosts do

      collection do
        get "tags" => "hosts#tags"
      end

      get "update_facts" => "hosts#update_facts"
      get "update_check_config" => "hosts#update_check_config"

      resources :checks do
        get "metrics" => "metrics#index_for_check"
      end
      resources :metrics
      resources :triggers
    end

    resources :repos
    resources :commands do
      get "opts"
      post "run"
    end

    resources :users do
      collection do
        get "valid"
        get "impersonate"
        post "confirm_password"
      end
    end

    resources :checks
    resources :on_calls
    resources :triggers
    resources :actions
    resources :annotations
  end


  ##############################################################################
  # VIEW ROUTES
  #
  # These routes serve up HTML for bootstrapping the app, i.e., on initial
  # navigation to the app.

  # replaced by login resource above
  # get 'login' => 'sessions#new', :as => :login

  get 'forgot_password' => "application#default_route"

  get 'getting_started' => "inventory/hosts#index"

  get 'profile' => "ui#default"
  get 'profile/edit' => "ui#default"
  get 'profile/enable_2fa' => "ui#default"

  get "/inventory" => "inventory/hosts#index"
  namespace :inventory do
    get "/search/:query" => "hosts#index"
    resources :hosts
  end

  get "/monitoring" => "monitoring/base#index"
  namespace :monitoring do
    resources :check_templates
    resources :on_calls
    resources :hosts do

      resources :checks
      resources :triggers do
        resources :actions
      end
      resources :metrics

    end
  end

  get "/repository" => "repository#index"
  get "/repository/new" => "repository#new"
  get "/repository/:id" => "repository#show"

  get "/runbooks" => "runbooks/base#index"
  namespace :runbooks do
  end

  ##############################################################################
  # MISC

  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq"

end
