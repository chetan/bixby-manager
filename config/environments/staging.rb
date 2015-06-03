Bixby::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like nginx, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable Rails's static asset server (Apache or nginx will already do this).
  config.serve_static_files = false

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Generate digests for assets URLs.
  config.assets.digest = true

  # Version of your assets, change this if you want to expire all your assets.
  config.assets.version = '1.1'

  # minification
  config.assets.compress       = true
  config.assets.css_compressor = :sass
  config.assets.js_compressor  = :uglifier

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  config.assets.precompile << %w(*.png *.jpg *.jpeg *.gif)               # vendor/assets/images
  config.assets.precompile << %w(*.otf *.eot *.svg *.ttf *.woff *.woff2) # font assets



  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # make sure the webserver passes the X-Forwarded-Proto header!
  # config.force_ssl = true

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = "http://assets.example.com"

  #############
  # EMAIL SETUP
  config.action_mailer.delivery_method = :sendmail
  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false


  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  config.middleware.insert_before "Rack::Sendfile", "Rack::Health"

  ###############
  # LOGGING SETUP

  # Disable automatic flushing of the log to improve performance.
  # config.autoflush_log = false

  config.log_level = :debug

  # Prepend all log lines with the following tags
  config.log_tags = [ :subdomain, :uuid ]

  # enable lograge gem
  config.lograge.enabled = true

  # add time to lograge
  config.lograge.custom_options = lambda do |event|
    { :time => event.time }
  end

  # Set the logging destination(s)
  config.log_to = %w[file]

  # Show the logging configuration on STDOUT
  config.show_log_configuration = false

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
end
