
listen 8080, :tcp_nopush => true
worker_processes 6
# timeout 60

working_directory "/var/www/bixby/current"
pid "/var/www/bixby/shared/pids/unicorn.pid"
stdout_path "/var/www/bixby/shared/log/unicorn.log"
stderr_path "/var/www/bixby/shared/log/unicorn.log"

# tune
preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

# timeout 60
check_client_connection false

before_exec do |server|
  ENV['BUNDLE_GEMFILE'] = "/var/www/bixby/current/Gemfile"
end

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!


  # This allows a new master process to incrementally
  # phase out the old master process with SIGTTOU to avoid a
  # thundering herd (especially in the "preload_app false" case)
  # when doing a transparent upgrade.  The last worker spawned
  # will then kill off the old master process with a SIGQUIT.
  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end

end

after_fork do |server, worker|
  # per-process listener ports for debugging/admin/migrations
  # addr = "127.0.0.1:#{9293 + worker.nr}"
  # server.listen(addr, :tries => -1, :delay => 5, :tcp_nopush => true)

  # the following is *required* for Rails + "preload_app true",
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection

  # if preload_app is true, then you may also want to check and
  # restart any other shared sockets/descriptors such as Memcached,
  # and Redis.  TokyoCabinet file handles are safe to reuse
  # between any number of forked children (assuming your kernel
  # correctly implements pread()/pwrite() system calls)
end

# Setup logger - see config/logging.rb for docs
require "logging"
Logging.format_as :inspect
Logging.appenders.rolling_file( 'file',
  :filename => File.join(Rails.root, "unicorn-#{Rails.env}.log"),
  :keep => 7,
  :age => 'daily',
  :truncate => false,
  :auto_flushing => true,
  :layout => Logging.layouts.pattern(:pattern => '%.1l, [%d] %5l -- %c: %m\n')
)
Logging.appenders["file"].reopen
Logging.logger.root.appenders = ["file"]
logger(Logging.logger[Unicorn])
