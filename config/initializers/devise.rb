
Devise.setup do |config|
  config.secret_key ||= "temp" # set during bootstrap

  # ==> Mailer Configuration
  # config.mailer_sender = 'please-change-me-at-config-initializers-devise@example.com'
  # config.mailer = 'Devise::Mailer'

  # ==> ORM configuration
  require 'devise/orm/active_record'

  # ==> Configuration for any authentication mechanism
  # Configure which keys are used when authenticating a user. The default is
  # just :email. You can configure it to use [:username, :subdomain], so for
  # authenticating a user, both parameters are required. Remember that those
  # parameters are used only when authenticating and not when retrieving from
  # session. If you need permissions, you should implement that in a before filter.
  # You can also supply a hash where the value is a boolean determining whether
  # or not authentication should be aborted when the value is not present.
  config.authentication_keys = [ :username ]

  # Configure parameters from the request object used for authentication. Each entry
  # given should be a request method and it will automatically be passed to the
  # find_for_authentication method and considered in your model lookup. For instance,
  # if you set :request_keys to [:subdomain], :subdomain will be used on authentication.
  # The same considerations mentioned for authentication_keys also apply to request_keys.
  # config.request_keys = [ :username ]

  config.case_insensitive_keys = [ :email, :username ]
  config.strip_whitespace_keys = [ :email, :username ]

  # Tell if authentication through request.params is enabled. True by default.
  # It can be set to an array that will enable params authentication only for the
  # given strategies, for example, `config.params_authenticatable = [:database]` will
  # enable it only for database (email + password) authentication.
  config.params_authenticatable = true

  # Tell if authentication through HTTP Auth is enabled. False by default.
  config.http_authenticatable = false

  # If http headers should be returned for AJAX requests. True by default.
  config.http_authenticatable_on_xhr = false
  config.navigational_formats = ["*/*", :html, :json]

  # The realm used in Http Basic Authentication. 'Application' by default.
  # config.http_authentication_realm = 'Application'

  # It will change confirmation, password recovery and other workflows
  # to behave the same regardless if the e-mail provided was right or wrong.
  # Does not affect registerable.
  # config.paranoid = true

  # By default Devise will store the user in session. You can skip storage for
  # particular strategies by setting this option.
  # Notice that if you are skipping storage for all authentication paths, you
  # may want to disable generating routes to Devise's sessions controller by
  # passing :skip => :sessions to `devise_for` in your config/routes.rb
  config.skip_session_storage = [:http_auth]

  # By default, Devise cleans up the CSRF token on authentication to
  # avoid CSRF token fixation attacks. This means that, when using AJAX
  # requests for sign in and sign up, you need to get a new CSRF token
  # from the server. You can disable this option at your own risk.
  config.clean_up_csrf_token_on_authentication = true

  # ==> Configuration for :database_authenticatable
  config.pepper ||= "temp"

  # ==> Configuration for :confirmable
  config.allow_unconfirmed_access_for = 0.days
  config.confirm_within = 1.days
  config.reconfirmable = true
  config.confirmation_keys = [ :email ]

  # ==> Configuration for :rememberable
  config.remember_for = 2.weeks
  config.extend_remember_period = true
  config.rememberable_options = {:secure => true}

  # ==> Configuration for :validatable
  config.password_length = 8..128
  config.email_regexp = /\A[^@]+@[^@]+\z/

  # ==> Configuration for :timeoutable
  config.timeout_in = 30.days
  config.expire_auth_token_on_timeout = false

  # ==> Configuration for :lockable
  config.lock_strategy = :failed_attempts
  config.unlock_keys = [ :email ]
  config.unlock_strategy = :email
  config.maximum_attempts = 5
  config.last_attempt_warning = false

  # ==> Configuration for :recoverable
  config.reset_password_keys = [ :username, :email ]
  config.reset_password_within = 6.hours

  # ==> Configuration for :encryptable
  require "devise/encryptable/encryptors/scrypt"
  config.encryptor = :scrypt

  # ==> Scopes configuration
  # Turn scoped views on. Before rendering "sessions/new", it will first check for
  # "users/sessions/new". It's turned off by default because it's slower if you
  # are using only default views.
  # config.scoped_views = false

  # Configure the default scope given to Warden. By default it's the first
  # devise role declared in your routes (usually :user).
  # config.default_scope = :user

  # Set this configuration to false if you want /users/sign_out to sign out
  # only the current scope. By default, Devise signs out all scopes.
  # config.sign_out_all_scopes = true

  # ==> Navigation configuration
  # Lists the formats that should be treated as navigational. Formats like
  # :html, should redirect to the sign in page when the user does not have
  # access, but formats like :xml or :json, should return 401.
  #
  # If you have any extra navigational formats, like :iphone or :mobile, you
  # should add them to the navigational formats lists.
  #
  # The "*/*" below is required to match Internet Explorer requests.
  # config.navigational_formats = ['*/*', :html]

  # The default HTTP method used to sign out a resource. Default is :delete.
  config.sign_out_via = :delete

  # ==> OmniAuth
  # Add a new OmniAuth provider. Check the wiki for more information on setting
  # up on your models and hooks.
  # config.omniauth :github, 'APP_ID', 'APP_SECRET', :scope => 'user,public_repo'

  # ==> Warden configuration
  # If you want to use other strategies, that are not supported by Devise, or
  # change the failure app, you can configure them inside the config.warden block.
  #
  require "devise/custom_failure"
  config.warden do |manager|
    manager.failure_app = Devise::CustomFailure
    # manager.intercept_401 = false
    # manager.default_strategies(:scope => :user).unshift :some_external_strategy
  end

  # ==> Mountable engine configurations
  # When using Devise inside an engine, let's call it `MyEngine`, and this engine
  # is mountable, there are some extra configurations to be taken into account.
  # The following options are available, assuming the engine is mounted as:
  #
  #     mount MyEngine, at: '/my_engine'
  #
  # The router that invoked `devise_for`, in the example above, would be:
  # config.router_name = :my_engine
  #
  # When using omniauth, Devise cannot automatically set Omniauth path,
  # so you need to do it manually. For the users scope, it would be:
  # config.omniauth_path_prefix = '/my_engine/users/auth'
end
