
ENV["RAILS_ENV"] = "test"

require File.expand_path('../../../config/environment', __FILE__)
require 'rails/test_help'

# load curb first so webmock can stub it out as necessary
require 'curb'
require 'curb_threadpool'
require 'webmock'
require 'mocha/setup'
require 'mock_redis'

# setup database_cleaner
require 'database_cleaner'
DatabaseCleaner.strategy = :truncation
