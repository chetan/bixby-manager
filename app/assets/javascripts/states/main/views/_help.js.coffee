namespace "Bixby.view", (exports, top) ->

  class exports.Help extends Stark.Partial
    className: "help"
    template: "main/_help"

    events:
      "shown.bs.popover span.help a": (e) ->
        $(".popover a").attr("target", "_blank") # make sure links open in new windows

    after_render: ->
      @$("span.help a").popover({ content: @markdown(@body), html: true })

    dispose: ->
      super
      @$("span.help a").popover("destroy")
