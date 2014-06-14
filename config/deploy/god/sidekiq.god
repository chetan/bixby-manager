
# https://github.com/mperham/sidekiq/wiki/Advanced-Options
# https://github.com/mperham/sidekiq/wiki/Signals

God.watch do |w|
  w.dir      = RAILS_ROOT
  w.name     = "sidekiq"
  w.group    = "bixby"
  w.log      = "#{RAILS_ROOT}/log/god.#{w.name}.log"
  w.pid_file = "#{RAILS_ROOT}/tmp/pids/sidekiq.pid"

  w.interval = 30.seconds

  w.env      = { "QUEUE" => "*", "RAILS_ENV" => RAILS_ENV }
  w.start    = "#{RVM_WRAPPER} bundle exec sidekiq -e #{RAILS_ENV} -d -C #{RAILS_ROOT}/config/deploy/sidekiq.yml"
  w.stop     = "kill -TERM `cat #{w.pid_file}`"

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
      on.condition(:process_exits)
    end
  end

  # restart if memory gets too high
  w.transition(:up, :restart) do |on|
    on.condition(:memory_usage) do |c|
      c.above = 350.megabytes
      c.times = 2
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
