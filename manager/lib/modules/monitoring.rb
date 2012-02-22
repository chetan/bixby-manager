
class Monitoring < API

  GET_OPTIONS = "--options"
  GET_METRICS = "--monitor"

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

  # Update the check configuration for the specified Agent
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

    exec_mon(agent, command)

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

    cmd = CommandSpec.new(:repo => "vendor",
            :bundle => "system/monitoring",
            :args => " -- #{args} " + File.join(command.relative_path, "bin", command.command))

    lang = "ruby"
    if command.command =~ /\.rb$/ then
      lang = "ruby"
    end
    cmd.command = "#{lang}_wrapper.rb"
    cmd.stdin = command.stdin
    cmd.validate

    ret = exec_with_wrapper(agent, cmd, command)
    if not ret.success? then
      # raise error
    end

    if ret.stdout then
      begin
        return JSON.parse(ret.stdout)
      rescue Exception => ex
      end
    end

    return ret
  end

end
