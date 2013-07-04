Bixby::Application.routes.draw do

  # Default route - show login page (redirects to /inventory if logged in)
  root :to => 'sessions#new'

  # API Controller endpoint
  match '/api' => 'api#handle'


  ##############################################################################
  # RESTFUL ROUTES
  # (API CALLS)
  #
  # These routes are primarily used for CRUD style actions on resources

  namespace :rest, :module => "rest/models" do

    resources :hosts do
      get "update_facts" => "hosts#update_facts"

      resources :checks
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
      end
    end

    resources :on_calls
    resources :triggers
    resources :actions
  end

  # Other actions
  post 'login'  => 'sessions#create',  :as => :login
  post 'logout' => 'sessions#destroy', :as => :logout


  ##############################################################################
  # VIEW ROUTES
  #
  # These routes serve up HTML for bootstrapping the app, i.e., on initial
  # navigation to the app.

  get 'login' => 'sessions#new', :as => :login

  get 'getting_started' => "ui#default"

  get 'profile' => "ui#default"
  get 'profile/edit' => "ui#default"

  get "/inventory" => "inventory::hosts#index"
  namespace :inventory do
    get "/search/:query" => "hosts#index"
    resources :hosts
  end

  get "/monitoring" => "monitoring::base#index"
  namespace :monitoring do
    resources :on_calls
    resources :hosts do

      resources :checks
      resources :triggers do
        resources :actions
      end
      resources :metrics

    end
  end

  get "/repository" => "repository::base#index"
  get "/repository/new" => "repository::base#new"
  namespace :repository do
  end


  ##############################################################################
  # MISC

  if Object.const_defined? :BIXBY_CONFIG and BIXBY_CONFIG[:scheduler] == "sidekiq" then
    require "sidekiq/web"
    mount Sidekiq::Web => "/sidekiq"
  end


  ##############################################################################
  # DOCS

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'

end
