
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

    agent = get_model(agent, Agent)

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

    agent = get_model(agent, Agent)

    command = CommandSpec.new( :repo => "vendor", :bundle => "system/monitoring",
                               :command => "mon_daemon.rb", :args => "restart" )

    return exec(agent, command)
  end

  # Add a check to a host. Updates the associated agent's configs in the
  # background.
  #
  # @param [Host] host
  # @param [Command] command
  # @param [Hash] args  Arguments for the check
  #
  # @return [Check]
  # @raise [CommandException]
  def add_check(host, command, args)

    host = get_model(host, Host)
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

    # update checks in bg
    job = Bixby::Scheduler::Job.create(Bixby::Monitoring, :update_check_config,
            host.agent.id)
    Bixby::Scheduler.new.schedule_in(0, job)

    return check
  end

  # Test the given list of metrics for triggers
  #
  # @param [Array<Metric>] metrics
  def test_metrics(metrics)

    all_triggers = get_all_triggers(metrics)
    metrics.each do |metric|

      triggers = all_triggers.find_all { |a|
        a.metric_id == metric.id or a.check_id == metric.check_id
      }
      next if triggers.blank?

      triggers.each do |trigger|

        user = OnCall.for_org(metric.org).current_user

        if trigger.test_value(metric.last_value) then
          # trigger is triggered, raise a notification

          if trigger.severity == metric.status then
            next # already in this state, skip
          end

          # store history
          TriggerHistory.record(metric, trigger, user)
          metric.status = trigger.severity # warning or critical for now
          metric.save!

          # notify (email only for now)
          MonitoringMailer.alert(metric, trigger, user).deliver

        elsif metric.status > Metric::Status::NORMAL then
          # trigger is back to normal level
          TriggerHistory.record(metric, trigger, user)
          metric.status = Metric::Status::NORMAL
          metric.save!

          # notify (email only for now)
          MonitoringMailer.alert(metric, trigger, user).deliver
        end

      end # triggers.each
    end # metrics.each
  end # test_metrics()



  private

  # Get all triggers matching the list of metrics (in a single query)
  def get_all_triggers(metrics)
    metric_ids = []
    check_ids = []
    metrics.each do |m|
      metric_ids << m.id
      check_ids << m.check_id
    end

    return Trigger.where("metric_id IN (?) OR check_id IN (?)",
                         metric_ids,
                         check_ids.sort.uniq)
  end

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
