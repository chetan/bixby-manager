
namespace 'Bixby.model', (exports, top) ->

  class exports.CommandLog extends Stark.Model
    @key: "command_log"

    @props
      _strings: ["command", "host", "user", "stdout", "stderr"]
      _dates:   "requested_at"
      _numbers: ["org_id", "user_id", "agent_id", "command_id", "scheduled_command_id", "time_taken", "exec_code", "status"]
      _bools:   ["exec_status"]
      _misc:    "args"

    params: [ { name: "command_log", set_id: true } ]
    urlRoot: "/rest/command_logs"

  class exports.CommandLogList extends Stark.Collection
    model: exports.CommandLog
    @key: "command_logs"
    url: "/rest/command_logs"

  class exports.ScheduledCommandLogList extends Stark.Collection
    model: exports.CommandLog
    @key: "command_logs"
    state:
      pageSize: 10
    params: ["scheduled_command"]
    url: -> "/rest/command_logs?scheduled_command_id=#{@scheduled_command_id}"
