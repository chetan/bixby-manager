namespace "Bixby.view.inventory", (exports, top) ->

  class exports.HostMetadata extends Stark.View
    template: "inventory/_metadata"
    bindings: [ "host" ]

    render: ->
      @metadata = _.sortBy(@metadata, "key")
      super

    after_render: ->
      # show a popover for long values
      @$("tbody tr").each (i, el) ->
        el = $(el)
        dc = el.attr("data-content")
        if dc.length > 40
          el.attr("data-content", "<pre>#{dc}</pre>")
          el.popover({html: true})
