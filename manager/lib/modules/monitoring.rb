
class Monitoring < API

  GET_OPTIONS = "--options"
  GET_METRICS = "--monitor"

  # Get command options specific to the specified agent
  #
  # @param [Agent] agent
  # @param [CommandSpec] command
  # @return [Hash] list of options with their possible values
  def get_command_options(agent, command)

    #c = CommandSpec.new({ :repo => "vendor", :bundle => "baz", :command => "ls", :args => "/tmp" })
    return exec_mon(agent, command, GET_OPTIONS)
  end

  # Manually initiate a Check and return the response Hash
  #
  # @param [Check] check
  # @return [Hash]
  #   * :timestamp [FixNum]
  #   * :metrics [Hash] key/value pairs of metrics
  #   * :errors [Array<String>] list of errors, if any
  #   * :status [String] OK, WARNING, CRITICAL, UNKNOWN, TIMEOUT
  #   * :key [String] base key name
  def run_check(check)

    command = create_spec(check.command)
    command.stdin = check.args.to_json

    return exec_mon(check.agent, command, GET_METRICS)
  end

  private

  # run with wrapper cmd
  def exec_mon(agent, command, args)

    command = create_spec(command)

    cmd = CommandSpec.new(:repo => "vendor",
            :bundle => "system/monitoring",
            :args => args + " " + File.join(command.relative_path, "bin", command.command))

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

    JSON.parse(ret.stdout)
  end

end
