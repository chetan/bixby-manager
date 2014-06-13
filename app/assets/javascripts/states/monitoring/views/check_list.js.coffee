namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.CheckList extends Stark.View
    el: "div.monitoring_content"
    template: "monitoring/check_list"

    links:
      # add checks
      ".add_check": [ "mon_hosts_checks_new", (el) ->
        return { host: @host }
        ]

      # add triggers
      ".add_trigger": [ "mon_hosts_triggers_new", (el) ->
        return { host: @host, metrics: @metrics, checks: @checks }
        ]

    after_render: ->
      super()

      graphs = @metrics.map (m) -> m.graph
      @sync_helper = new Bixby.monitoring.PanSyncHelper(graphs)
