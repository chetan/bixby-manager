
namespace 'Bixby.model', (exports, top) ->

  class exports.Trigger extends Stark.Model

    url: ->
      "/monitoring/hosts/#{@host_id || @host.id}/triggers" # id is appended if avail for update


  class exports.TriggerList extends Stark.Collection
    model: exports.Trigger
    url: -> "/monitoring/hosts/#{@host_id || @host.id}/triggers"

    initialize: (data) ->
      @extract_param(data, "host")
