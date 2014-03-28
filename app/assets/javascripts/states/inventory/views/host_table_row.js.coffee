namespace "Bixby.view.inventory", (exports, top) ->

  class exports.HostTableRow extends Stark.View
    template:  "inventory/_host_table_row"
    tagName:   "div"
    className: "host"

    events:
      "click a.edit": ->
        @host_editor.show()

    links:
      "div.actions a.monitoring": [ "mon_view_host", (el) -> { host: @host } ]
      "div.body a.host":          [ "inv_view_host", (el) -> { host: @host } ]

    bindings: [ "host" ]

    render: ->
      super
      @host_editor ||= @partial(exports.HostEditor, { host: @host })
      @
