
COMMON_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "../../../common/lib/common"))
if File.exists? COMMON_ROOT then
    # means we're runnin in a dev environment
    $:.unshift(COMMON_ROOT)
end

require 'manager'
require 'api/modules/base_module'
require 'api/modules/bundle_repository'

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
  require "modules/scheduler/#{DEVOPS_CONFIG[:scheduler]}"
end
require 'modules/scheduler'
Scheduler.configure(DEVOPS_CONFIG)
