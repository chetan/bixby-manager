
require "mongoid"
require "test_guard"
require "minitest/unit" # require this first so we can stub properly
require "micron/minitest"

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
