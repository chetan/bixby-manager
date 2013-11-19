
def spork_running?
  ENV.include? "DRB"
end

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

  require "mongoid"

  if not(spork_running? or zeus_running?) then
    # load now if neither spork (DRB) or zeus are running
    # (usually during manual rake test run)
    load_simplecov()
  end

  require "test_guard"
  require "minitest/unit" # require this first so we can stub properly
  require "micron/minitest"

  require "setup/prefork"
end

def load_simplecov
  require "easycov"
  EasyCov.path = "coverage"
  EasyCov.filters << EasyCov::IGNORE_GEMS << EasyCov::IGNORE_STDLIB
  EasyCov.start
end

def bootstrap_tests

  if spork_running? or zeus_running? then
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

  # require files in order to force coverage reports
  # [ "lib", "app" ].each do |d|
  #   Dir.glob(File.join(Rails.root, d, "**/*.rb")).each{ |f| next if f =~ %r{lib/capistrano}; require f }
  # end
end

if Object.const_defined? :Spork then

  #uncomment the following line to use spork with the debugger
  #require 'spork/ext/ruby-debug'

  Spork.prefork do
    prefork()
  end

  Spork.each_run do
    bootstrap_tests()
  end

  # Spork.after_each_run do
  # end

elsif zeus_running? then
  prefork()

else
  # normal 'rake test'
  prefork()
  bootstrap_tests()

end
