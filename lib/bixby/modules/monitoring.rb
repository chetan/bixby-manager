
module Bixby

class Monitoring < API

  GET_OPTIONS = "--options"
  GET_METRICS = "--monitor"

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
