require 'zeus/rails'

module Mongoid
  VERSION = "4.0.0"
  def self.running_with_passenger?
    false
  end
end

class CustomPlan < Zeus::Rails

  RAILS_ROOT = File.expand_path(File.dirname(__FILE__))

  # def my_custom_command
  #  # see https://github.com/burke/zeus/blob/master/docs/ruby/modifying.md
  # end

  def after_fork
  end

  def test_helper
    require "helper"
  end

  def test
    bootstrap_tests()
    require "micron"
    require "micron/app"
    ::Micron::App.new.run()
  end

  def server
    require 'rails/commands/server'
    server = ::Rails::Server.new
    Dir.chdir(::Rails.application.root)
    bixby_bootstrap()
    server.start
  end

  def console
    require 'rails/commands/console'
    bixby_bootstrap()
    if defined?(Pry) && IRB == Pry
      require "pry"
      Pry.start
    else
      ::Rails::Console.start(::Rails.application)
    end
  end

  def rake
    bixby_bootstrap()
    Rake.application.run
  end


  private

  def bixby_bootstrap
    require "#{RAILS_ROOT}/config/initializers/bixby_bootstrap"
  end

end

Zeus.plan = CustomPlan.new
