
require 'micron/test_case/redir_logging'

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

      include Micron::TestCase::RedirLogging
      self.redir_logger = Logging.logger[Bixby]

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

      def create_bundle(path)
        repo = @repo || Repo.first || FactoryGirl.create(:repo)
        bundle = Bundle.new(:repo => repo, :path => path)
        bundle.save
        bundle
      end

    end

    module Models
    end

    module Modules
    end

    module RailsExt
    end

    module Controllers
      module Rest
        module Models
        end
      end
    end

    module Views
      module Models
      end
    end
  end

end
