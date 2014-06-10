Bixby::Application.routes.draw do

  # put 'users/password' => "users#reset_password"
  devise_scope :user do
    get  "/login"  => "sessions#new"
    post "/login"  => "sessions#create"
    post "/logout" => "sessions#destroy"
    post "/users/password" => "passwords#create"
    put  "/users/password" => "passwords#update"
  end
  devise_for :users, :controllers => { :sessions => 'sessions' }

  # Default route
  root "inventory/hosts#index"

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
    end

    resources :users do
      collection do
        get "valid"
        get "impersonate"
      end
    end

    resources :checks, :only => [:show, :destroy, :update]
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


  ##############################################################################
  # MISC

  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq"


  ##############################################################################
  # DOCS

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

end
