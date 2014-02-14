
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

    # create a list of commands which need to be provisioned
    # and also gather check config
    config = []
    commands = {}

    checks = Check.where("agent_id = ?", agent.id)
    checks.each do |check|
      command = command_for_check(check)
      bundle = File.join(command.repo, command.bundle)
      if not commands.include? bundle then
        commands[bundle] = command
      end

      config << { :interval => check.normal_interval, :retry => check.retry_interval,
                  :timeout => check.timeout, :command => command }
    end

    Provisioning.new.provision(agent, commands.values) # provision all at once

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
  # @param [Host] host              host to which the check will be attached
  # @param [Command] command        check command
  # @param [Hash] args              arguments for the check
  # @param [Agent] agent            agent which will execute the check (default: same as host)
  #
  # @return [Check]
  # @raise [CommandException]
  def add_check(host, command, args, agent=nil)

    host = get_model(host, Host)
    command = get_model(command, Command)

    if agent.blank? then
      agent = host.agent
    else
      agent = get_model(agent, Agent)
    end

    # create resource name
    # TODO check if command *has* any options - look at defaults, etc
    config = create_spec(command).load_config()
    name = config["key"] || ""
    args = nil if args and args.empty?
    if args then
      name += "." if not name.empty?
      name += args.values.first

      # remove empty args
      args.delete_if{ |k,v| v.nil? or v.empty? }
    end

    check = Check.new
    check.host            = host
    check.agent           = agent
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

      triggered = []
      reset = []

      triggers.each do |trigger|
        logger.debug { "testing #{metric.key}: #{metric.last_value} #{trigger.sign} #{trigger.threshold.to_s}" }
        if trigger.test_value(metric.last_value) or trigger.test_status(metric.last_status) then
          # trigger is over threshold
          if trigger.severity == metric.status then
            next # already in this state, skip
          end
          logger.debug { "#{metric.key}: triggered" }
          triggered << trigger

        elsif metric.status != Metric::Status::OK then
          # trigger has returned to normal
          logger.debug { "#{metric.key}: reset" }
          reset << trigger
        end
      end # triggers.each

      # process triggers over threshold
      filter_triggers(triggered).each do |trigger|
        # store history
        history = TriggerHistory.record(metric, trigger)
        metric.status = trigger.severity
        metric.save!

        # process all actions
        trigger.actions.each do |action|
          if action.alert? then
            # notify
            oncall = OnCall.find(action.target_id)
            MonitoringMailer.alert(metric, trigger, oncall.current_user).deliver

          elsif action.exec? then
            # run command
            cmd = Command.find(action.target_id)
            # TODO run it
          end
        end
      end # triggered

      # only proceed if all triggers did not match
      next if not triggered.blank?

      # metric is back to normal level
      filter_triggers(reset).each do |trigger|
        metric.status = Metric::Status::OK
        metric.save!
        previous_history = TriggerHistory.previous_for_trigger(trigger)
        history = TriggerHistory.record(metric, trigger)

        # process all actions
        trigger.actions.each do |action|
          if action.alert? then
            # notify
            oncall = OnCall.find(action.target_id)
            MonitoringMailer.alert(metric, trigger, oncall.current_user).deliver
          end
          # we ignore exec actions for now
        end
      end # reset

    end # metrics.each
  end # test_metrics()

  # Create a new trigger
  #
  # @param [Hash] opts
  # @option opts [Check] check
  # @option opts [Metric] metric
  # @option opts [String] severity  "warning" or "critical"
  # @option opts [String] sign      Treshold sign
  # @option opts [String] threshold
  # @option opts [Array<String] status    List of statuses which will trigger (optional)
  #
  # @return [Trigger]
  def add_trigger(opts)
    opts = opts.with_indifferent_access
    t = Trigger.new
    t.check_id  = opts[:check_id]
    t.metric_id = opts[:metric_id]
    t.set_severity(opts[:severity])
    t.sign      = opts[:sign].to_sym
    t.threshold = opts[:threshold]
    t.status    = array(opts[:status]).map{ |s| s.upcase }

    t.save!
    t
  end

  # Create a new trigger action
  #
  # @param [Hash] opts
  # @option opts [Fixnum] trigger_id
  # @option opts [String] action_type
  # @option opts [Fixnum] target_id
  # @option opts [String] args
  #
  # @return [Trigger]
  def add_trigger_action(opts)
    a = Action.new
    a.trigger_id  = opts[:trigger_id]
    a.action_type = Action::Type.lookup(opts[:action_type])
    a.target_id   = opts[:target_id].to_i
    a.args        = opts[:args]

    a.save!
    a
  end


  private

  # Filter the given list of triggers
  # * If any are CRITICAL, returns only those
  # * Otherwise returns all (no filtering done)
  #
  # @param [Array<Trigger>] triggers
  #
  # @return [Array<Trigger>] filtered list of triggers
  def filter_triggers(triggers)
    if triggers.size > 1 then
      # get only CRITICAL triggers
      filtered = triggers.find_all { |t| t.severity == Trigger::Severity::CRITICAL }
    end
    if filtered.blank? then
      filtered = triggers
    end
    return filtered
  end

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

require "bixby/modules/monitoring/hooks"
