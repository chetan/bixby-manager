# ## Schema Information
#
# Table name: `command_logs`
#
# ### Columns
#
# Name                | Type               | Attributes
# ------------------- | ------------------ | ---------------------------
# **`id`**            | `integer`          | `not null, primary key`
# **`org_id`**        | `integer`          |
# **`user_id`**       | `integer`          |
# **`agent_id`**      | `integer`          |
# **`command_id`**    | `integer`          |
# **`stdin`**         | `text`             |
# **`args`**          | `text`             |
# **`exec_status`**   | `boolean`          |
# **`exec_code`**     | `integer`          |
# **`status`**        | `integer`          |
# **`stdout`**        | `text`             |
# **`stderr`**        | `text`             |
# **`requested_at`**  | `datetime`         |
# **`time_taken`**    | `decimal(10, 3)`   |
#
# ### Indexes
#
# * `command_logs_agent_id_fk`:
#     * **`agent_id`**
# * `command_logs_command_id_fk`:
#     * **`command_id`**
# * `command_logs_org_id_fk`:
#     * **`org_id`**
#

class CommandLog < ActiveRecord::Base

  # all fields are read-only
  attr_readonly :agent_id, :command_id, :stdin, :args, :env,
                :exec_status, :exec_code,
                :status, :stdout, :stderr,
                :requested_at, :time_taken

  multi_tenant :via => :agent

  belongs_to :org
  belongs_to :user
  belongs_to :agent
  belongs_to :command

  serialize :env, JSONColumn.new

  # Create a new log entry for the given remote exec block
  #
  # @param [Agent] agent
  # @param [CommandSpec] request
  # @param [User] user                [Optional] the user running the command
  #
  # @return [JsonResponse]
  def self.log_exec(agent, request, user=nil)

    requested_at = Time.new
    response = nil
    time_taken = Benchmark.realtime do
      response = yield # grab the JsonResponse
    end

    c = CommandLog.new
    c.org = agent.host.org
    c.user = user
    c.agent = agent
    c.command = Command.from_command_spec(request)
    c.stdin = request.stdin
    c.args = request.args
    c.env = request.env
    c.exec_status = response.success?
    c.exec_code =  response.code

    cr = Bixby::CommandResponse.from_json_response(response)
    c.status = cr.status
    c.stdout = cr.stdout if not cr.stdout.blank?
    c.stderr = cr.stderr if not cr.stderr.blank?

    c.requested_at = requested_at
    c.time_taken = time_taken

    c.save!

    response.log = c # pass it back inside the JsonResponse
    return response
  end

  def self.for_user(user)
    where(:org_id => user.org_id).order(:requested_at => :desc)
  end

end
