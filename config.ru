# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

# print a thread dump on SIGALRM
# kill -ALRM `cat /var/www/bixby/tmp/pids/puma.pid`
trap 'SIGALRM' do
  Thread.list.each do |thread|
    STDERR.puts "Thread-#{thread.object_id.to_s(36)}"
    STDERR.puts thread.backtrace.join("\n    \\_ ")
    STDERR.puts "-"
    STDERR.puts
  end
end

# run Bixby::Application

run Rack::URLMap.new(
  "/"      => Bixby::Application,
  "/wsapi" => Bixby::WebSocketServer
)

# Start agent listener
Bixby::Application.config.after_initialize do
  Bixby::AgentRegistry.redis_channel.start!
end
