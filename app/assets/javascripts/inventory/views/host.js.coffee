namespace "Bixby.view.inventory", (exports, top) ->

  class exports.Host extends Stark.View
    el: "div.inventory_content"
    template: "inventory/host"

    bindings: [ "host" ]

    events: {
      "click a.refresh-facts": (e) ->
        e.preventDefault()
        $.get("/rest/hosts/" + @host.id + "/update_facts")
    }

    links: {
      "div.actions a.monitoring": [ "mon_view_host", (el) -> { host: @host } ]
    }

    render: ->
      super

      if @_md?
        @_md.dispose()

      @_md = @partial exports.HostMetadata,
        { metadata: @host.get("metadata") },
        "div.host div.metadata"

      @_he ||= @partial(exports.HostEditor, { host: @host })
      @_he.setButton( @$("span.edit button.edit") )
