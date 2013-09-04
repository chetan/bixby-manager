
# this is mainly to skip loading bixby-related coded when using 'spork' or 'zeus'
# instead, we load this after forking to run our tests


# Rails.logger.info "$0: #{$0}"

# check for the zeus 'slave' process - this is started during 'zeus start'
# and our actual processes are forked from there. don't bootstrap for slaves!
is_zeus_slave = ($0 =~ /zeus slave/)

if !is_zeus_slave && (Rails.env != "test" or ENV["BOOTSTRAPNOW"] or
  not(Module.const_defined?(:Spork))) then

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

  # set rails secret token
  if Rails.env != "test" and BIXBY_CONFIG[:secret_token].blank? then
    raise "secret_token not set in bixby.yml for the '#{::Rails.env}' environment!"
  end
  Bixby::Application.config.secret_key_base = BIXBY_CONFIG[:secret_token]

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

  # Start EventMachine/pubsub server
  Bixby::AgentRegistry.redis_channel.start!

  Rails.logger.info "Successfully bootstrapped BIXBY!"
end
