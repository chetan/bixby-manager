# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)


# run Bixby::Application

run Rack::URLMap.new(
  "/"      => Bixby::Application,
  "/wsapi" => Bixby::WebSocketServer
)

# Start agent listener
Bixby::Application.config.after_initialize do
  Bixby::AgentRegistry.redis_channel.start!
end
