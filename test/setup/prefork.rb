
ENV["RAILS_ENV"] = "test"

require File.expand_path('../../../config/environment', __FILE__)
require 'rails/test_help'

# load curb first so webmock can stub it out as necessary
require 'curb'
require 'curb_threadpool'
require 'webmock'
require 'mocha/setup'
require 'mock_redis'

class ActiveSupport::TestCase

  include WebMock::API
  include Mocha::API

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

# setup database_cleaner
require 'database_cleaner'
DatabaseCleaner.strategy = :truncation
