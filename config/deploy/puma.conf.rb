#!/usr/bin/env puma

directory "/var/www/bixby/current"
rackup "config.ru"

environment ENV["RAILS_ENV"] || "production"
daemonize true

pidfile         '/var/www/bixby/current/tmp/pids/puma.pid'
state_path      '/var/www/bixby/current/tmp/pids/puma.state'
stdout_redirect '/var/www/bixby/current/log/puma.log', '/var/www/bixby/current/log/puma.log', true

# Disable request logging.
# The default is “false”.
# quiet

# Min, Max threads
threads 8, 32

bind 'tcp://127.0.0.1:8080'

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

# === Puma control rack application ===

# Start the puma control rack application on “url”. This application can
# be communicated with to control the main server. Additionally, you can
# provide an authentication token, so all requests to the control server
# will need to include that token as a query parameter. This allows for
# simple authentication.
#
# Check out https://github.com/puma/puma/blob/master/lib/puma/app/status.rb
# to see what the app has available.
#
activate_control_app 'unix:///var/run/pumactl.sock'
