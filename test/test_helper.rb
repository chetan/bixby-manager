
def spork_running?
  ENV.include? "DRB"
end

def zeus_running?
  File.exists? '.zeus.sock' and Module.const_defined?(:Zeus)
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

  if not(spork_running? or zeus_running?) then
    # load now if neither spork (DRB) or zeus are running
    # (usually during manual rake test run)
    load_simplecov()
  end

  require "test_guard"
  require "test_prefork"
end

def load_simplecov
  return if ENV["SIMPLECOV_STARTED"]
  begin
    require 'simplecov'
    SimpleCov.start do
      merge_timeout 7200

      add_filter '/test/'
      add_filter '/config/'

      add_group 'Controllers', 'app/controllers'
      add_group 'Models', 'app/models'
      add_group 'Helpers', 'app/helpers'
      add_group 'Libraries', 'lib'
    end
    ENV["SIMPLECOV_STARTED"] = "1"
  rescue Exception => ex
    warn "simplecov not available"
  end
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

  require "test_setup" # base TestCase

  # require files in order to force coverage reports
  [ "lib", "app" ].each do |d|
    Dir.glob(File.join(Rails.root, d, "**/*.rb")).each{ |f| next if f =~ %r{lib/capistrano}; require f }
  end
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
