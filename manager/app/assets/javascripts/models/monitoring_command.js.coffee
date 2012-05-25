
namespace 'Bixby.model', (exports, top) ->



  class exports.MonitoringCommand extends Stark.Model
    urlRoot: "/monitoring/commands"
    command: ->
      cmd = @get("command")
      cmd.replace(/monitoring\//, "")
    has_options: ->
      opts = @get("options")
      if ! opts? || _.keys(opts).length == 0
        return false

      return true



  class exports.MonitoringCommandList extends Stark.Collection
    model: exports.MonitoringCommand
    url: "/monitoring/commands"



  class exports.MonitoringCommandOpts extends exports.MonitoringCommand
    url: -> "/monitoring/hosts/#{@host.id}/command/#{@id}/opts"
