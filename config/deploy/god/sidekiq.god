
God.watch do |w|
  w.dir      = "#{RAILS_ROOT}"
  w.name     = "sidekiq-bixby"
  w.interval = 30.seconds
  w.log      = "#{RAILS_ROOT}/log/god.#{w.name}.log"

  w.env      = { "QUEUE" => "*", "RAILS_ENV" => RAILS_ENV }
  w.start    = "#{BIN_PATH}/bundle exec sidekiq -e #{RAILS_ENV} -c 25 -q schedules" # 25 is default

  w.uid = 'chetan'
  w.gid = 'chetan'

  # restart if memory gets too high
  w.transition(:up, :restart) do |on|
    on.condition(:memory_usage) do |c|
      c.above = 350.megabytes
      c.times = 2
    end
  end

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
      c.interval = 5.seconds
    end

    # failsafe
    on.condition(:tries) do |c|
      c.times = 5
      c.transition = :start
      c.interval = 5.seconds
    end
  end

  # start if process is not running
  w.transition(:up, :start) do |on|
    on.condition(:process_exits)
  end

end
