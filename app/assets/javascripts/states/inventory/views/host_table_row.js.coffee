namespace "Bixby.view.inventory", (exports, top) ->

  class exports.HostTableRow extends Stark.Partial
    template:  "inventory/_host_table_row"
    tagName:   "div"
    className: "host"

    links:
      "div.body a.monitoring": [ "mon_view_host", (el) -> { host: @host } ]
      "div.body a.host":       [ "inv_view_host", (el) -> { host: @host } ]

    bindings: [ "host" ]

    last_seen_label: ->
      if seen = @host.get("last_seen_at")
        "Agent last seen at " + @format_datetime(seen)
      else
        "Agent has never connected"
