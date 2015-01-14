
require "active_support" # fix load order issues with mongoid, which directly requires active_support/core_ext
require "mongoid"
require "test_guard"
require "minitest"
require "minitest/unit" # require this first so we can stub properly
require "micron/minitest"

ENV["RAILS_ENV"] = "test"

require File.expand_path('../../../config/environment', __FILE__)
require 'rails/test_help'

require 'httpi'
require 'continuum/http/httpi'
require 'webmock'
require 'mocha/setup'
require 'mock_redis'

# setup database_cleaner
require 'database_cleaner'
DatabaseCleaner.strategy = :truncation
