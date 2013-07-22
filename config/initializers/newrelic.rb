
if Rails.env == "development" then
  require "newrelic_rpm"
  require "newrelic-redis"
  require "newrelic-curb"
  require "newrelic-middleware"
  require "newrelic_moped"
end
