
class CommandLog < ActiveRecord::Base

  # all fields are read-only
  attr_readonly :agent_id, :command_id, :args,
                :exec_status, :exec_code,
                :status, :stdout, :stderr,
                :created_at

  multi_tenant :via => :agent

  belongs_to :agent
  belongs_to :command

  # Create a new log entry for the given JSONResponse
  #
  # @param [CommandSpec] request
  # @param [JsonResponse] response
  def self.create(agent, request, response)
    c = CommandLog.new
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

    c.save!
    c
  end

end
