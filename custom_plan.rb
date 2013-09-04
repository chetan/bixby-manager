require 'zeus/rails'

class CustomPlan < Zeus::Rails

  RAILS_ROOT = File.expand_path(File.dirname(__FILE__))

  # def my_custom_command
  #  # see https://github.com/burke/zeus/blob/master/docs/ruby/modifying.md
  # end

  def after_fork
  end

  def test
    bootstrap_tests()
    super # runs the tests
  end

   def server
    require 'rails/commands/server'
    server = ::Rails::Server.new
    Dir.chdir(::Rails.application.root)
    require "#{RAILS_ROOT}/config/initializers/bixby_bootstrap"
    server.start
  end

end

Zeus.plan = CustomPlan.new
