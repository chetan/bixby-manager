
namespace 'Bixby.model', (exports, top) ->

  class exports.MonitoringCommand extends Stark.Model
    urlRoot: "/rest/commands"

    command: ->
      cmd = @get("command")
      cmd.replace(/monitoring\//, "")

    has_options: ->
      opts? && ! _.isEmpty(@get("options"))

  class exports.MonitoringCommandList extends exports.CommandList
    model: exports.MonitoringCommand
    url: "/rest/commands?type=monitoring"


  class exports.MonitoringCommandOpts extends exports.MonitoringCommand
    url: ->
      "/rest/commands/#{@id}/opts?host_id=#{@host.id}"
