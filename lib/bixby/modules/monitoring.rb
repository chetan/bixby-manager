
module Bixby

class Monitoring < API

  GET_OPTIONS = "--options"
  GET_METRICS = "--monitor"

  Bixby::Metrics.add_hook(:put_check_result) do |metrics|
    Monitoring.new.test_metrics(metrics)
  end

  # Get command options specific to the specified agent
  #
  # @param [Agent] agent
  # @param [CommandSpec] command
  # @return [Hash] list of options with their possible values
  def get_command_options(agent, command)
    return exec_mon(agent, command, GET_OPTIONS)
  end

  # Manually initiate a Check and return the response Hash
  #
  # @param [Check] check
  # @return [Hash]
  #   * :key [String] base key name
  #   * :status [String] OK, WARNING, CRITICAL, UNKNOWN, TIMEOUT
  #   * :timestamp [FixNum]
  #   * :metrics [Hash] key/value pairs of metrics
  #   * :errors [Array<String>] list of errors, if any
  def run_check(check)
    command = command_for_check(check)
    return exec_mon(check.agent, command, GET_METRICS)
  end

  # Update the check configuration for the specified Agent and restart the
  # monitoring daemon.
  #
  # @param [Agent] agent
  def update_check_config(agent)

    config = []
    checks = Check.where("agent_id = ?", agent.id)
    checks.each do |check|
      command = command_for_check(check)
      config << { :interval => check.normal_interval, :retry => check.retry_interval,
                  :timeout => check.timeout, :command => command }
    end

    command = CommandSpec.new( :repo => "vendor", :bundle => "system/monitoring",
                               :command => "update_check_config.rb", :stdin => config.to_json )

    return exec_mon(agent, command) # TODO handle err here?
  end

  # Restart the monitoring daemon. Starts if not already running.
  #
  # @param [Agent] agent
  def restart_mon_daemon(agent)

    command = CommandSpec.new( :repo => "vendor", :bundle => "system/monitoring",
                               :command => "mon_daemon.rb", :args => "restart" )

    exec_mon(agent, command)
  end

  # Add a check to a host
  #
  # @param [Host] host
  # @param [Command] command
  # @param [Hash] args  Arguments for the check
  #
  # @return [Check]
  def add_check(host, command, args)

    config = create_spec(command).load_config()

    # create resource name
    # TODO check if command *has* any options - look at defaults, etc
    name = config["key"] || ""
    args = nil if args and args.empty?
    if args then
      name += "." if not name.empty?
      name += args.values.first
    end

    # TODO host & agent can be different
    check = Check.new
    check.host            = host
    check.agent           = host.agent
    check.command         = command
    check.args            = args
    check.normal_interval = 60
    check.retry_interval  = 60
    check.plot            = true
    check.enabled         = true
    check.save!

    return check
  end

  # Test the given list of metrics for alerts
  #
  # @param [Array<Metric>] metrics
  def test_metrics(metrics)

    metrics.each do |metric|

      alert = Alert.for_metric(metric).first
      next if alert.blank?

      if alert.test_value(metric.last_value) then
        # raise a notification
        user = OnCall.for_org(metric.org).current_user
        # store history
        AlertHistory.record(metric, alert, user)
        # notify (email only for now)
        MonitoringMailer.alert(metric, alert, user).deliver
      end
    end

  end



  private

  # Create a CommandSpec for the given Check
  #
  # @param [Check] check
  # @return [CommandSpec]
  def command_for_check(check)
    command = create_spec(check.command)
    check.args[:check_id] = check.id
    command.stdin = check.args.to_json
    return command
  end

  # run with wrapper cmd
  def exec_mon(agent, command, args = "")

    command = create_spec(command)
    args = command.args if args.blank?

    cmd = CommandSpec.new(:repo => "vendor",
            :bundle => "system/monitoring",
            :args => File.join(command.relative_path, "bin", command.command) + " -- #{args}")

    lang = "ruby"
    if command.command =~ /\.rb$/ then
      lang = "ruby"
    end
    cmd.command = "#{lang}_wrapper.rb"
    cmd.stdin = command.stdin
    cmd.validate

    ret = exec_with_wrapper(agent, cmd, command)
    if not ret.success? then
      puts "exec failed with: "
      puts ret.stdout
      puts ret.stderr
      raise "exec failed"
    end

    # TODO should we return CommandResponse here?
    if ret.stdout then
      begin
        return MultiJson.load(ret.stdout)
      rescue Exception => ex
      end
    end

    return ret
  end

end

end # Bixby
