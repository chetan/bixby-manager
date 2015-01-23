
God.watch do |w|
  w.dir      = RAILS_ROOT
  w.name     = "puma"
  w.group    = "bixby"
  w.log      = "#{RAILS_ROOT}/log/god.#{w.name}.log"
  w.pid_file = "#{RAILS_ROOT}/tmp/pids/puma.pid"

  w.interval = 30.seconds # default

  pumactl = "#{RVM_WRAPPER} bundle exec script/puma"

  w.start = "#{pumactl} start"
  w.stop = "#{pumactl} stop" # QUIT gracefully shuts down workers
  w.restart = "#{pumactl} restart" # cause the server to re-create itself & gracefully exit

  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds

  w.uid = USER
  w.gid = GROUP

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

  # for some reason this fails when running on travis
  # god[3883]: Condition 'God::Conditions::ProcessExits' requires an event system but none has been loaded
  if ENV["USER"] != "travis" then
    # start if process is not running
    w.transition(:up, :start) do |on|
      on.condition(:process_exits) { |c| c.notify = 'support' }
    end
  end

  # restart if memory or cpu is too high or http error on /
  w.transition(:up, :restart) do |on|
    on.condition(:memory_usage) do |c|
      c.interval = 30
      c.above = 350.megabytes
      c.times = [3, 5] # 3 out of 5
      c.notify = 'support'
    end

    on.condition(:cpu_usage) do |c|
      c.interval = 20
      c.above = 50.percent
      c.times = 5
      c.notify = 'support'
    end

    on.condition(:http_response_code) do |c|
      c.host = 'localhost'
      c.port = '9292'
      c.path = '/rack_health?god'
      c.code_is_not = 200
      c.timeout = 10.seconds
      c.times = [3, 5] # 3 out of 5
      c.notify = 'support'
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
      c.notify = 'support'
    end
  end
end
