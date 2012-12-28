
module Bixby
  module Test

    class TestCase < ActiveSupport::TestCase
      def setup
        DatabaseCleaner.start
        WebMock.reset!
      end
      def teardown
        DatabaseCleaner.clean
        MultiTenant.current_tenant = nil
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
