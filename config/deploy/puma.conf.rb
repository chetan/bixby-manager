#!/usr/bin/env puma

directory "/var/www/bixby/current"
rackup "config.ru"

environment ENV["RAILS_ENV"] || "production"
daemonize true
drain_on_shutdown true

# Puma control rack application (used by pumactl to send signals)
activate_control_app 'unix:///var/www/bixby/current/tmp/pids/pumactl.sock'

pidfile         '/var/www/bixby/current/tmp/pids/puma.pid'
state_path      '/var/www/bixby/current/tmp/pids/puma.state'
stdout_redirect '/var/www/bixby/current/log/puma.log', '/var/www/bixby/current/log/puma.log', true

# Disable request logging.
# The default is “false”.
# quiet

# Min, Max threads
threads 8, 32

if (ENV["RAILS_ENV"] || "production") == "development"
  bind 'tcp://127.0.0.1:3000'
else
  bind 'tcp://127.0.0.1:9292'
end


# Code to run before doing a restart. This code should
# close log files, database connections, etc.
#
# This can be called multiple times to add code each time.
#
# on_restart do
#   puts 'On restart...'
# end

# Command to use to restart puma. This should be just how to
# load puma itself (ie. 'ruby -Ilib bin/puma'), not the arguments
# to puma, as those are the same as the original process.
#
# restart_command '/u/app/lolcat/bin/restart_puma'

# === Cluster mode ===

# How many worker processes to run.
#
# The default is “0”.
#
# workers 2
# preload_app!

# Code to run when a worker boots to setup the process before booting
# the app.
#
# This can be called multiple times to add hooks.
#
# on_worker_boot do
#   puts 'On worker boot...'
# end
