
namespace 'Bixby.model', (exports, top) ->

  class exports.Host extends Stark.Model
    urlRoot: "/inventory"

    initialize: (data) ->
      @extract_param(data, "host", true)

    name: ->
      @get("alias") || @get("hostname") || @get("ip")

  class exports.HostList extends Stark.Collection
    model: exports.Host
    url: "/inventory"
