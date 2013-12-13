namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.MetricList extends Stark.View
    el: "div.monitoring_content"
    template: "monitoring/resource_list"
    events: {
    }

    links: {

      # add resources/checks
      ".add_resource_link": [ "mon_hosts_resources_new", (el) ->
        return { host: @host }
        ]

      # add triggers on resources
      ".add_trigger_link": [ "mon_hosts_triggers_new", (el) ->
        return { host: @host, metrics: @metrics, checks: @checks }
        ]

      # metric detail page
      "div.metric a.metric": [ "mon_hosts_resources_metric", (el) ->
          check = @checks.get $(el).attr("check_id")
          metric = @metrics.get $(el).attr("metric_id")
          return { host: @host, check: check, metric: metric }
        ]
    }

    after_render: ->
      super()

      graphs = @metrics.map (m) -> m.graph
      @sync_helper = new Bixby.monitoring.PanSyncHelper(graphs)
