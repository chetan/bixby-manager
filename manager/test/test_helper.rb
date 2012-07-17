
def prefork
  root = File.expand_path(File.dirname(__FILE__))
  if not $:.include? root then
    # add to library load path
    $: << root
  end
  require "test_prefork"
  require "test_setup"
end

def bootstrap_tests
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
    # SimpleCov.at_exit do
    #   SimpleCov.result.format!
    # end
  rescue Exception => ex
  end

  begin
    require "#{Rails.root}/test/factories"
  rescue
  end

  ENV["BOOTSTRAPNOW"] = "1"
  require "#{Rails.root.to_s}/config/initializers/bixby_bootstrap"

  # require files in order to force coverage reports
  [ "lib", "app" ].each do |d|
    Dir.glob(File.join(Rails.root, d, "**/*.rb")).each{ |f| require f }
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

else
  # normal 'rake test'
  prefork()
  bootstrap_tests()

end
