
namespace "Bixby.view.inventory", (exports, top) ->

  class exports.Layout extends Stark.View
    el: $("#content")
    template: "inventory/layout"

  class exports.HostTable extends Stark.View
    el: "div.inventory_content"
    template: "inventory/host_table"
    events: {
      "click .monitoring_host_link": (e) ->
        host = @hosts.get $(e.target).attr("host_id")
        @transition "mon_view_host", { host: host }
    }
