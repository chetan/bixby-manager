namespace "Bixby.view.inventory", (exports, top) ->

  class exports.HostTableNewRow extends Stark.View
    template:  "inventory/_host_table_new_row"
    tagName:   "div"
    className: "host"

    links:
      "div.actions a.monitoring": [ "mon_view_host", (el) -> { host: @host } ]
      "div.body a.host":          [ "inv_view_host", (el) -> { host: @host } ]

    events:
      "click button.approve": (e) ->
        @host.remove_tag("new")
        @host.save()

      "click button.reject": (e) ->
        @host.remove_tag("new")
        @host.add_tag("reject")
        @host.save()

    bindings: [ "host" ]
