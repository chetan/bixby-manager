
Bixby::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # cache_classes includes Rack::Lock which forces us into a single-threaded environment
  # disable it so we can work properly with the agent in an async manner
  config.middleware.delete "Rack::Lock"

  # Do not eager load code on boot.
  config.eager_load = false

  # disable caching in dev
  config.cache_store = :null_store

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # change prefix to avoid clash with local precompile
  config.assets.prefix = "/dev-assets"

  # Do not compress assets
  config.assets.compress = false

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  #
  # slows page reloads drastically because of sequential/blocking JS loading
  # about 6 sec with this enabled vs 600ms without it
  config.assets.debug = false

  # don't quiet temporarily
  # config.quiet_assets = false

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Set the logging destination(s)
  config.log_to = %w[stdout file]

  # Show the logging configuration on STDOUT
  config.show_log_configuration = true

  # bullet config
  config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = true
    Bullet.console = true
    # Bullet.growl = true
    Bullet.rails_logger = true
    Bullet.alert = false
    Bullet.add_footer = false
    # Bullet.stacktrace_includes = [ 'your_gem', 'your_middleware' ]
  end

end
