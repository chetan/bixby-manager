
require 'rubygems'
require 'spork'

#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  require File.expand_path(File.dirname(__FILE__)) + "/test_prefork"
end

Spork.each_run do

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

  ENV["BOOTSTRAPNOW"] = "1"
  require "#{Rails.root.to_s}/config/initializers/devops_bootstrap"
  Dir.glob(Rails.root + "/lib/**/*.rb").each{ |f| require f }

end

# Spork.after_each_run do
# end
