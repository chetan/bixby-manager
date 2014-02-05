namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.Check extends Stark.Partial

    className: "check"
    template: "monitoring/_check"

    links: {
      "a.check": [ "mon_hosts_check", (el) ->
        metrics = @metrics
        { host: @host, check: @check, metrics: metrics }
      ]
    }

