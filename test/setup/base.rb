
class ActiveSupport::TestCase

  include WebMock::API
  include Mocha::API

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

end

module Bixby
  module Test

    class TestCase < ActiveSupport::TestCase
      def before_setup
        super
        # send logging to stdout for duration of test
        bixby = Logging.logger[Bixby]
        @_old_log_appenders = bixby.appenders
        bixby.clear_appenders
        bixby.add_appenders("stdout_test")
      end
      def setup
        DatabaseCleaner.start
        WebMock.reset!
      end
      def teardown
        DatabaseCleaner.clean
        MultiTenant.current_tenant = nil
        ActionMailer::Base.deliveries.clear
        WebMock.reset!
      end
      def after_teardown
        super
        Logging.logger[Bixby].add_appenders(@_old_log_appenders)
      end
    end

    module Models
    end

    module Modules
    end

    module RailsExt
    end

    module Controllers
    end

    module Views
      module Models
      end
    end
  end

end
