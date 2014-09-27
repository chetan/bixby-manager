
namespace 'Bixby.model', (exports, top) ->

  class exports.ScheduledCommand extends Stark.Model

    @key: "scheduled_command"
    urlRoot: "/rest/scheduled_commands"

    params: [ { name: "scheduled_command", set_id: true } ]

    @validate: (type, str, cb) ->
      $.ajax @::urlRoot + "/validate",
        type: "GET"
        dataType: "json"
        data: { type: type, string: str }
        success: cb

    @validate_cron: (str, cb) ->
      @validate("cron", str, cb)

    @validate_natural: (str, cb) ->
      @validate("natural", str, cb)

  class exports.ScheduledCommandList extends Stark.Collection
    model: exports.ScheduledCommand
    @key: "scheduled_commands"
    url: -> "/rest/hosts/#{@host_id || @host.id}/triggers"
    params: [ "host" ]
