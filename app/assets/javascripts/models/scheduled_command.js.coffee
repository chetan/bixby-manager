
namespace 'Bixby.model', (exports, top) ->

  class exports.ScheduledCommand extends Stark.Model

    @key: "scheduled_command"
    @props
      _strings: ["agent_ids", "owner", "stdin", "args", "schedule", "alert_users", "alert_emails", "command", "hosts", "org", "status"]
      _ints:    ["command_id", "created_by", "schedule_type", "alert_on", "run_count"]
      _dates:   ["created_at", "updated_at", "deleted_at", "scheduled_at", "completed_at", "last_run", "next_run"]
      _bools:   ["enabled"]
      _other:   ["env", "host_ids"]
    urlRoot: "/rest/scheduled_commands"

    params: [ { name: "scheduled_command", set_id: true } ]

    @validate: (type, str, allow_past, cb) ->
      if _.isFunction(allow_past)
        cb = allow_past
        allow_past = false
      $.ajax @::urlRoot + "/validate",
        type: "GET"
        dataType: "json"
        data: { type: type, string: str, allow_past: allow_past }
        success: cb

    @validate_cron: (str, cb) ->
      @validate("cron", str, cb)

    @validate_natural: (str, cb) ->
      @validate("natural", str, cb)

    is_cron: ->
      @schedule_type == 1

    is_once: ->
      @schedule_type == 2

    alert_on_success: ->
      return (@alert_on & 1) == 1

    alert_on_error: ->
      return (@alert_on & 2) == 2

    command_log: ->
      if last = @get("last_run_log")
        new B.m.CommandLog(last)

    env_str: ->
      B.m.Command.env_str(@env)

    # Disable this ScheduledCommand
    disable: (cb) ->
      @toggle("/disable", cb)

    # Enable this ScheduledCommand
    enable: (cb) ->
      @toggle("/enable", cb)

    # Toggle this ScheduledCommand
    toggle: (method, cb) ->
      @ajax @url(method),
        data: {id: @id}
        success: (data, textStatus, jqXHR) =>
          @set(data)
          cb.call(@)

    # Run this command again with the same inputs, targets, etc
    repeat: (time, cb) ->
      @ajax @url("/repeat"),
        data: {scheduled_at: time}
        success: (data, textStatus, jqXHR) =>
          sc = new ScheduledCommand(data)
          cb.call(@, sc)

  class exports.ScheduledCommandList extends Stark.Collection
    model: exports.ScheduledCommand
    @key: "scheduled_commands"
    url: "/rest/scheduled_commands"

  class exports.ScheduledCommandHistoryList extends Stark.Collection
    model: exports.ScheduledCommand
    @key: "scheduled_commands"
    url: "/rest/scheduled_commands/history"
