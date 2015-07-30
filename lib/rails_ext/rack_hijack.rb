
# Instead of logging a standard access_log line, write a proper log of the connection
#
# e.g., instead of this:
# 127.0.0.1 - - [30/Jul/2015:10:46:11 -0400] "GET /wsapi HTTP/1.1" -1 - 0.0640
# write this:
# I, [2015-07-30 15:06:12]  INFO -- Puma::CommonLogger:23: new websocket connection from 127.0.0.1

require "puma/commonlogger"

module Puma
  class CommonLogger

    private

    def log_hijacking(env, status, header, began_at)
      ::Logging::Logger[self].info {
        ip = env['HTTP_X_FORWARDED_FOR'] || env["REMOTE_ADDR"] || "-"
        "new websocket connection from #{ip}"
      }
    end
  end
end
