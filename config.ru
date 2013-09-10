# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

wsapp = Rack::Builder.new do
  use Rails::Rack::Logger
  run Bixby::WebSocketServer
end

run Rack::URLMap.new(
  "/"      => Bixby::Application,
  "/wsapi" => wsapp
)
