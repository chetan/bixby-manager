namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.HostSummary extends Stark.View
    el: "div.monitoring_content"
    template: "monitoring/host_summary"

    links:
      ".edit_checks": [ "mon_hosts_check_table", (el) -> return { host: @host } ]
      ".add_check":   [ "mon_hosts_checks_new", (el) -> return { host: @host } ]
      ".add_trigger": [ "mon_hosts_triggers_new", (el) ->
        return { host: @host, metrics: @metrics, checks: @checks }
        ]
      ".all_metrics":   [ "mon_view_host_all", (el) -> return { host: @host } ]

    # Display the metrics for the given keys
    display_metrics: (keys...) ->
      _.each keys, (key) =>
        _.each @metrics.where({key: key}), (metric) =>
          __out__ += @include_partial(_bvm.Metric, {metric: metric, metric_label: metric.custom_display_name()})

    after_render: ->
      super()

      graphs = @metrics.map (m) -> m.graph
      @sync_helper = new Bixby.monitoring.PanSyncHelper(graphs)

      # only display the top controls if the bottom ones are off page
      if ! _.isScrolledIntoView(@$("p.bottom"))
        @$("p.top").removeClass("hidden").show()
