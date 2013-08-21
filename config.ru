# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)


# run Bixby::Application

run Rack::URLMap.new(
  "/"      => Bixby::Application,
  "/wsapi" => Bixby::WebSocketServer
)
