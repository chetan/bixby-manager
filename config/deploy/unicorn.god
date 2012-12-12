
# https://gist.github.com/208581
# http://unicorn.bogomips.org/SIGNALS.html

rails_env = ENV['RAILS_ENV'] || 'production'
rails_root = ENV['RAILS_ROOT'] || "/var/www/bixby/current"

God.watch do |w|
  w.name = "unicorn-bixby"
  w.log = "#{rails_root}/log/god.#{w.name}.log"
  w.dir = rails_root
  w.pid_file = "#{rails_root}/tmp/pids/unicorn.pid"

  w.interval = 30.seconds # default

  # unicorn needs to be run from the rails root
  w.start = "bundle exec unicorn_rails -c #{rails_root}/config/deploy/unicorn.conf.rb -E #{rails_env} -D"

  # QUIT gracefully shuts down workers
  w.stop = "kill -QUIT `cat #{w.pid_file}`"

  # USR2 causes the master to re-create itself and spawn a new worker pool
  w.restart = "kill -USR2 `cat #{w.pid_file}`"

  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds

  w.uid = 'chetan'
  w.gid = 'chetan'

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
      c.port = '8080'
      c.path = '/'
      c.code_is = 500
      c.timeout = 10.seconds
      c.times = [3, 5] # 3 out of 5
    end
  end

  # lifecycle
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end


# This will ride alongside god and kill any rogue memory-greedy
# processes. Their sacrifice is for the greater good.

unicorn_worker_memory_limit = 300_000

Thread.new do
  loop do
    begin
      # unicorn workers
      #
      # ps output line format:
      # 31580 275444 unicorn_rails worker[15] -c /data/github/current/config/unicorn.rb -E production -D
      # pid ram command

      lines = `ps -e -www -o pid,rss,command | grep '[u]nicorn_rails worker'`.split("\n")
      lines.each do |line|
        parts = line.split(' ')
        if parts[1].to_i > unicorn_worker_memory_limit
          # tell the worker to die after it finishes serving its request
          ::Process.kill('QUIT', parts[0].to_i)
        end
      end
    rescue Object
      # don't die ever once we've tested this
      nil
    end

    sleep 30
  end
end
