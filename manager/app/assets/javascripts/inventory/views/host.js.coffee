namespace "Bixby.view.inventory", (exports, top) ->

  class exports.Host extends Stark.View
    el: "div.inventory_content"
    template: "inventory/host"

    bindings: [ "host" ]

    render: ->
      super

      if @_md?
        @_md.dispose()

      @_md = @partial exports.HostMetadata,
        { metadata: @host.get("metadata") },
        "div.host div.metadata"

      @_he ||= @partial(exports.HostEditor, { host: @host })
      @_he.setButton( @$("span.edit button.edit") )
