namespace "Bixby.view.inventory", (exports, top) ->

  class exports.Host extends Stark.View
    el: "div.inventory_content"
    template: "inventory/host"

    bindings: [ "host" ]

    events: {
      "click button.refresh-facts": (e) ->
        e.preventDefault()
        return if $(e.target).hasClass("disabled")

        # modify button to display spinner
        $("button.refresh-facts").addClass("disabled")
        $("button.refresh-facts i").css({visibility: "hidden"})
        @spinner = new Bixby.view.Spinner($("button.refresh-facts"), { length: 3, width: 2, radius: 2, top: '-10px', left: '0' })

        view = @
        $.getJSON "/rest/hosts/" + @host.id + "/update_facts",
          (data, status, jqXHR) ->
            view.host = new Bixby.model.Host(data)
            view.redraw()
    }

    links: {
      "div.actions a.monitoring": [ "mon_view_host", (el) -> { host: @host } ]
    }

    render: ->
      super
      @_he = @partial(exports.HostEditor, { host: @host })
      @_he.setButton( @$("span.edit button.edit") )
      @
