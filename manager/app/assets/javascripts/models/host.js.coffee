
namespace 'Bixby.model', (exports, top) ->

  class exports.Host extends Stark.Model
    urlRoot: "/hosts"

    initialize: (data) ->
      @extract_param(data, "host", true)

    name: ->
      name = (@get("hostname") || @get("ip"))
      if @get("alias")?
        name += " (" + @get("alias") + ")"
      return name

    tags: ->
      return @get("tags").split(",")

  class exports.HostList extends Stark.Collection
    model: exports.Host
    url: "/hosts"
