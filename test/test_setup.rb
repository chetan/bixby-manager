
module Bixby
  module Test

    class TestCase < ActiveSupport::TestCase
      def setup
        DatabaseCleaner.start
        WebMock.reset!
      end
      def teardown
        DatabaseCleaner.clean
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
