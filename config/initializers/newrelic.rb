
if Rails.env == "development" then
  require "newrelic_rpm"
  require "newrelic-redis"
  require "newrelic-curb" if RUBY_PLATFORM != "java"
  require "newrelic-middleware"
  require "newrelic_moped"
end
