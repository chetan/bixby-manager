
class CommandLog < ActiveRecord::Base

  # all fields are read-only
  attr_readonly :agent_id, :command_id, :stdin, :args,
                :exec_status, :exec_code,
                :status, :stdout, :stderr,
                :requested_at, :time_taken

  multi_tenant :via => :agent

  belongs_to :org
  belongs_to :agent
  belongs_to :command

  # Create a new log entry for the given remote exec block
  #
  # @param [Agent] agent
  # @param [CommandSpec] request
  #
  # @return [JsonResponse]
  def self.log_exec(agent, request)

    requested_at = Time.new
    response = nil
    time_taken = Benchmark.realtime do
      response = yield
    end

    c = CommandLog.new
    c.org = agent.host.org
    c.agent = agent
    c.command = Command.from_command_spec(request)
    c.stdin = request.stdin
    c.args = request.args
    c.exec_status = response.success?
    c.exec_code =  response.code

    cr = Bixby::CommandResponse.from_json_response(response)
    c.status = cr.status
    c.stdout = cr.stdout if not cr.stdout.blank?
    c.stderr = cr.stderr if not cr.stderr.blank?

    c.requested_at = requested_at
    c.time_taken = time_taken

    c.save!

    return response
  end

end
