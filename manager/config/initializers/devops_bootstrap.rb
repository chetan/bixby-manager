# this is mainly to skip loading devops-related coded when using 'spork'
# instead, we load this after forking to run our tests
if Rails.env != "test" or ENV["BOOTSTRAPNOW"] then

  require 'manager'

  require 'modules'
  require 'rails_ext/json_column'

  # load devops.yml
  devops_config_filename = File.open(File.join(::Rails.root.to_s, "config", "devops.yml"))
  if not File.exists? devops_config_filename then
    raise "config/devops.yml not found!"
  end
  devops_config = YAML.load(devops_config_filename)
  if not devops_config.include? ::Rails.env then
    raise "devops.yml doesn't have a config for the '#{::Rails.env}' environment!"
  end
  DEVOPS_CONFIG = devops_config[::Rails.env].with_indifferent_access

  # setup bundle repo, manager uri
  Manager.root = DEVOPS_CONFIG[:manager][:root]
  BundleRepository.path = File.join(Manager.root, "/repo")
  BaseModule.manager_uri = DEVOPS_CONFIG[:manager][:uri]

  # setup the scheduler
  if DEVOPS_CONFIG[:scheduler] then
    # load a specific scheduler
    require "modules/scheduling/#{DEVOPS_CONFIG[:scheduler]}"
  end
  require "modules/scheduler"
  Scheduler.configure(DEVOPS_CONFIG)

  # setup metrics
  if DEVOPS_CONFIG[:metrics] then
    require "modules/metrics"
    require "modules/metrics/#{DEVOPS_CONFIG[:metrics]}"
    Metrics.configure(DEVOPS_CONFIG)
  end

  # rescan plugins
  Repository::BundleRepository.rescan_plugins << Metrics::RescanPlugin

end
