namespace "Bixby.view.inventory", (exports, top) ->

  class exports.HostMetadata extends Stark.Partial
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
          el.addClass("has-popover")
          el.attr("data-content", "<textarea class='form-control' disabled='true' rows='7'>#{dc}</textarea>")
          el.popover({html: true, container: "div.inventory", placement: "right"})

          # hide any other open popovers
          el.on "show.bs.popover", (e) ->
            $("tr.has-popover").each (i, tr) ->
              if tr != e.target
                $(tr).popover("hide")

          # reposition it
          el.on "shown.bs.popover", (e) ->
            left = $("table.metadata").width() + $("table.metadata").position().left + 20
            $("div.popover").css("left", left)

    dispose: ->
      $("div.popover").remove()
      super

