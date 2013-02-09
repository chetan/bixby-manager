# this is mainly to skip loading bixby-related coded when using 'spork'
# instead, we load this after forking to run our tests
if Rails.env != "test" or ENV["BOOTSTRAPNOW"] then

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
  BIXBY_CONFIG = bixby_config[::Rails.env].with_indifferent_access

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

end
