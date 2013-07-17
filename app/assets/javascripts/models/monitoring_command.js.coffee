
namespace 'Bixby.model', (exports, top) ->

  class exports.MonitoringCommand extends exports.Command

    get_command: ->
      cmd = @get("command")
      cmd.replace(/monitoring\//, "")

  class exports.MonitoringCommandList extends exports.CommandList
    model: exports.MonitoringCommand
    url: "/rest/commands?type=monitoring"


  class exports.MonitoringCommandOpts extends exports.MonitoringCommand
    url: ->
      "/rest/commands/#{@id}/opts?host_id=#{@host.id}"
