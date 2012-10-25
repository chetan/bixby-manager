
if Rails.env == "development" then
  require "newrelic_rpm"
  require "rpm_contrib"
  require "newrelic-redis"
end
