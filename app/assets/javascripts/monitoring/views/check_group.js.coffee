namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.CheckGroup extends Stark.View

    el: "div.monitoring_content"
    className: "check"
    template: "monitoring/_check"

    links: {
      "a.check": [ "mon_hosts_check", (el) ->
        metrics = @metrics
        { host: @host, check: @check, metrics: metrics }
      ]
    }

