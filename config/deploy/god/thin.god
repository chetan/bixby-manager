# == God config file
# http://god.rubyforge.org/
# Authors: Gump and michael@glauche.de
#
# Config file for god that configures watches for each instance of a thin server for
# each thin configuration file found in /etc/thin.
# In order to get it working on Ubuntu, I had to make a change to god as noted at
# the following blog:
# http://blog.alexgirard.com/ruby-one-line-to-save-god/
#
# Original from:
# https://github.com/macournoyer/thin/blob/master/example/thin.god
require 'yaml'

config_path = "#{RAILS_ROOT}/config/deploy/thin.yml"

config = YAML.load_file(config_path)
num_servers = config["servers"] ||= 1

cmd = "#{RVM_WRAPPER} bundle exec thin"

(0...num_servers).each do |i|

  # UNIX socket cluster use number 0 to 2 (for 3 servers)
  # and tcp cluster use port number 3000 to 3002.
  number = config['socket'] ? i : (config['port'] + i)

  God.watch do |w|
    w.group = "thin-bixby"
    w.name = "#{w.group}-#{number}"
    w.log = "#{RAILS_ROOT}/log/god.#{w.name}.log"

    w.interval = 30.seconds

    w.uid = config["user"] if config["user"]
    w.gid = config["group"] if config["group"]
    w.dir = config["chdir"]

    w.start = "#{cmd} start -C #{config_path} -o #{number}"
    w.start_grace = 10.seconds

    w.stop = "#{cmd} stop -C #{config_path} -o #{number}"
    w.stop_grace = 10.seconds

    w.restart = "#{cmd} restart -C #{config_path} -o #{number}"

    pid_path = File.join(config["chdir"], config["pid"])
    ext = File.extname(pid_path)

    w.pid_file = pid_path.gsub(/#{ext}$/, ".#{number}#{ext}")

    w.behavior(:clean_pid_file)

    # determine the state on startup
    w.transition(:init, { true => :up, false => :start }) do |on|
      on.condition(:process_running) do |c|
        c.running = true
      end
    end

    # determine when process has finished starting
    w.transition([:start, :restart], :up) do |on|
      on.condition(:process_running) do |c|
        c.running = true
      end

      # failsafe
      on.condition(:tries) do |c|
        c.times = 8
        c.within = 2.minutes
        c.transition = :start
      end
    end

    # start if process is not running
    w.transition(:up, :start) do |on|
      on.condition(:process_exits)
    end

    # restart if memory or cpu is too high or http error on /
    w.transition(:up, :restart) do |on|
      on.condition(:memory_usage) do |c|
        c.interval = 30
        c.above = 150.megabytes
        c.times = [3, 5] # 3 out of 5
      end

      on.condition(:cpu_usage) do |c|
        c.interval = 20
        c.above = 50.percent
        c.times = 5
      end

      on.condition(:http_response_code) do |c|
        c.host = 'localhost'
        c.port = number
        c.path = '/'
        c.code_is = 500
        c.timeout = 10.seconds
        c.times = [3, 5] # 3 out of 5
      end
    end

    w.lifecycle do |on|
      on.condition(:flapping) do |c|
        c.to_state = [:start, :restart]
        c.times = 5
        c.within = 5.minutes
        c.transition = :unmonitored
        c.retry_in = 10.minutes
        c.retry_times = 5
        c.retry_within = 2.hours
      end
    end

  end # God.watch
end # loop
