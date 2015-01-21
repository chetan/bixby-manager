
require 'rack/commonlogger'
require 'puma/rack_patch'

module Rack
  # Patch CommonLogger to use after_reply.
  #
  # Simply request this file and CommonLogger will be a bit more
  # efficient.
  class CommonLogger
    def log_hijacking(env, status, header, began_at)
      ::Logging::Logger[self].info {
        ip = env['HTTP_X_FORWARDED_FOR'] || env["REMOTE_ADDR"] || "-"
        "new websocket connection from #{ip}"
      }
    end
  end
end
