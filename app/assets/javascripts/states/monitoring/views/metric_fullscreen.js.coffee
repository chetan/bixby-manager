namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.MetricFullscreen extends Stark.View
    el: "div.monitoring_content"
    template: "monitoring/metric_fullscreen"

    links:
      "button.return": [ "mon_hosts_metric", -> { host: @host, check: @check, metric: @metric } ]

    after_render: ->
      if @graph = Bixby.monitoring.render_metric(@$("div.metric"), @metric)
        @sync_helper = new Bixby.monitoring.PanSyncHelper(@graph)
        @graph._bixby_touch_enabled = true # enable touch events in detailed view
