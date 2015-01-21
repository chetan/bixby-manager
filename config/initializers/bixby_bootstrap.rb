

# Rails.logger.info "$0: #{$0}"

# this (IF statement) is mainly to skip loading bixby-related coded when using
# 'spork' or 'zeus'. instead, we load this after forking

# check for the zeus 'slave' process - this is started during 'zeus start'
# and our actual processes are forked from there. don't bootstrap for slaves!
is_zeus_slave = ($0 =~ /zeus slave/)

if !is_zeus_slave && (Rails.env != "test" or ENV["BOOTSTRAPNOW"] or
  not(Module.const_defined?(:Spork))) then

  # Disable logging to STDOUT when running rake commands
  if $0 =~ /rake/ then # && ARGV.find{ |a| a =~ /(bixby|\-T)/ } then
    logger = Logging.logger.root
    old_log_appenders = logger.appenders
    logger.clear_appenders
    logger.add_appenders(old_log_appenders.reject{ |a| a.kind_of? Logging::Appenders::Stdout })
    Rails.logger.warn("Removed STDOUT appender since we are running in rake")
  end

  Bixby::ThreadDump.trap!

  Rails.logger.info "Bootstrapping BIXBY"

  require 'bixby'
  require 'rails_ext'

  # load api_view models
  Find.find(File.join(::Rails.root.to_s, "app", "views", "models")) do |path|
    next if not File.file? path
    require path
  end

  # load bixby.yml
  bixby_config_filename = File.open(File.join(::Rails.root.to_s, "config", "bixby.yml"))
  if not File.exists? bixby_config_filename then
    raise "config/bixby.yml not found!"
  end
  bixby_config = YAML.load(bixby_config_filename)
  if not bixby_config.include? ::Rails.env then
    raise "bixby.yml doesn't have a config for the '#{::Rails.env}' environment!"
  end
  if not Module.const_defined? :BIXBY_CONFIG then
    BIXBY_CONFIG = bixby_config[::Rails.env].with_indifferent_access
  end

  # use an asset host for serving static assets
  if host = BIXBY_CONFIG[:static_asset_host] then
    host = "//#{host}" if host[0, 2] != "//"
    Bixby::Application.config.action_controller.asset_host = host
    ActionController::Base.asset_host = host
  end

  # setup bundle repo, manager uri
  ENV["BIXBY_HOME"] = File.expand_path(BIXBY_CONFIG[:manager][:root])
  Bixby.manager_uri = BIXBY_CONFIG[:manager][:uri]

  # setup the scheduler
  if BIXBY_CONFIG[:scheduler] then
    require "bixby/modules/scheduler/#{BIXBY_CONFIG[:scheduler]}"
  end
  require "bixby/modules/scheduler"
  Bixby::Scheduler.configure(BIXBY_CONFIG)

  # setup metrics
  if BIXBY_CONFIG[:metrics] then
    require "bixby/modules/metrics"
    require "bixby/modules/metrics/#{BIXBY_CONFIG[:metrics]}"
    Bixby::Metrics.configure(BIXBY_CONFIG)
  end

  # rescan plugins
  Bixby::Repository.rescan_plugins << Bixby::Metrics::RescanPlugin

  # archie
  require "archie"
  Archie::Config.secret_key = BIXBY_CONFIG[:archie_secret_key]
  Archie::Config.pepper     = BIXBY_CONFIG[:archie_pepper]
  # set OTP encryption key
  Archie::Config.otp_secret_encryption_key     = BIXBY_CONFIG[:otp_secret_encryption_key]
  User.encrypted_attributes[:otp_secret][:key] = Archie::Config.otp_secret_encryption_key

  # set default url_for options
  uri = URI(Bixby.manager_uri)
  url_opts = {
    :host     => uri.host + (uri.port == uri.default_port ? "" : ":#{uri.port}"),
    :protocol => uri.scheme
  }
  Rails.application.config.action_mailer.default_url_options = url_opts.dup
  Rails.application.routes.default_url_options               = url_opts.dup

  Rails.application.config.action_mailer.default_options = {
    :from => BIXBY_CONFIG[:mailer_from]
  }

  # Start EventMachine/pubsub server
  if ENV["BIXBY_SKIP_EM"] != "1" then
    Bixby::AgentRegistry.redis_channel.start!
  end

  Rails.logger.info "Successfully bootstrapped BIXBY!"
end
