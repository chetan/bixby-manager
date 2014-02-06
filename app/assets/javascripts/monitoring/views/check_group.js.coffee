namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.CheckGroup extends Stark.View

    el: "div.monitoring_content"
    template: "monitoring/check_group"

    events: {
      "click button.return_host": (e) ->
        @transition "mon_view_host", {host: @host}
    }
