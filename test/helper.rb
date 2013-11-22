
def zeus_running?
  File.exists? '.zeus.sock' and Module.const_defined?(:Zeus)
end

module Mongoid
  def self.running_with_passenger?
    false
  end
end

def prefork
  root = File.expand_path(File.dirname(__FILE__))
  if not $:.include? root then
    # add to library load path
    $: << root
  end

  require "rubygems"
  if not defined? ::Bundler then
    require "bundler/setup"
  end

  if not(zeus_running?) then
    # load now if zeus is not running
    # (usually during manual rake test run)
    load_simplecov()
  end

  require "setup/prefork"
end

def load_simplecov
  require "easycov"
  EasyCov.path = "coverage"
  EasyCov.filters << EasyCov::IGNORE_GEMS << EasyCov::IGNORE_STDLIB
  EasyCov.start
end

def bootstrap_tests

  if zeus_running? then
    load_simplecov()
  end

  begin
    require "#{Rails.root}/test/factories"
  rescue
  end

  ENV["BOOTSTRAPNOW"] = "1"
  require "#{Rails.root.to_s}/config/initializers/bixby_bootstrap"

  require "setup/base"
  require "setup/base_controller"
  require "setup/stub_api"

  # Configure celluloid logger for tests
  require "celluloid"
  ::Celluloid.logger = ::Logging.logger["Celluloid"]
end

if zeus_running? then
  prefork()

else
  # normal 'rake test'
  prefork()
  bootstrap_tests()

end
