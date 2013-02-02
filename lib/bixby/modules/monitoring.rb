
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
  #
  # @return [Hash] list of options with their possible values
  # @raise [CommandException]
  def get_command_options(agent, command)
    command = create_spec(command)
    command.args = GET_OPTIONS
    ret = exec(agent, command)
    ret.raise!
    return ret.decode
  end

  # Manually initiate a Check and return the response Hash
  #
  # @param [Check] check
  #
  # @return [Hash]
  #   * :key [String] base key name
  #   * :status [String] OK, WARNING, CRITICAL, UNKNOWN, TIMEOUT
  #   * :timestamp [FixNum]
  #   * :metrics [Hash] key/value pairs of metrics
  #   * :errors [Array<String>] list of errors, if any
  #
  # @raise [CommandException]
  def run_check(check)
    command = command_for_check(check)
    command.args = GET_METRICS
    ret = exec(check.agent, command)
    ret.raise!
    return ret.decode
  end

  # Update the check configuration for the specified Agent and restart the
  # monitoring daemon.
  #
  # @param [Agent] agent
  #
  # @return [CommandResponse]
  # @raise [CommandException]
  def update_check_config(agent)

    provisioned = {}

    config = []
    checks = Check.where("agent_id = ?", agent.id)
    checks.each do |check|
      command = command_for_check(check)

      bundle = File.join(command.repo, command.bundle)
      if not provisioned.include? bundle then
        Provisioning.new.provision(agent, command)
        provisioned[bundle] = 1
      end

      config << { :interval => check.normal_interval, :retry => check.retry_interval,
                  :timeout => check.timeout, :command => command }
    end

    command = CommandSpec.new( :repo => "vendor", :bundle => "system/monitoring",
                               :command => "update_check_config.rb", :stdin => config.to_json )

    return exec(agent, command) # TODO handle err here?
  end

  # Restart the monitoring daemon. Starts if not already running.
  #
  # @param [Agent] agent
  #
  # @return [CommandResponse]
  # @raise [CommandException]
  def restart_mon_daemon(agent)

    command = CommandSpec.new( :repo => "vendor", :bundle => "system/monitoring",
                               :command => "mon_daemon.rb", :args => "restart" )

    return exec(agent, command)
  end

  # Add a check to a host
  #
  # @param [Host] host
  # @param [Command] command
  # @param [Hash] args  Arguments for the check
  #
  # @return [Check]
  # @raise [CommandException]
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

      user = OnCall.for_org(metric.org).current_user

      if alert.test_value(metric.last_value) then
        # alert is triggered, raise a notification

        if alert.severity == metric.status then
          next # already in this state, skip
        end

        # store history
        AlertHistory.record(metric, alert, user)
        metric.status = alert.severity # warning or critical for now
        metric.save!

        # notify (email only for now)
        MonitoringMailer.alert(metric, alert, user).deliver

      elsif metric.status > Metric::Status::NORMAL then
        # alert is back to normal level
        AlertHistory.record(metric, alert, user)
        metric.status = Metric::Status::NORMAL
        metric.save!

        # notify (email only for now)
        MonitoringMailer.alert(metric, alert, user).deliver
      end

    end # metrics.each
  end # test_metrics()



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

end

end # Bixby
