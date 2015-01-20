# This file is used by Rack-based servers to start the application.

ENV["IS_RAILS_SERVER"] = "1"

require ::File.expand_path('../config/environment',  __FILE__)

wsapp = Rack::Builder.new do
  use Rack::CommonLogger, Rails.logger
  run Bixby::WebSocketServer.new
end

run Rack::URLMap.new(
  "/"      => Bixby::Application,
  "/wsapi" => wsapp
)
