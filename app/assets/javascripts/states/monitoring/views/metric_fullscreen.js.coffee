namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.MetricFullscreen extends Stark.View
    el: "div.monitoring_content"
    template: "monitoring/metric_fullscreen"

    links:
      "button.return": [ "mon_hosts_metric", -> { host: @host, check: @check, metric: @metric } ]

    after_render: ->
      @bixby_graph = new Bixby.monitoring.Graph()
      @bixby_graph.touch_enabled = true
      if @graph = @bixby_graph.render(@$("div.metric"), @metric)
        @sync_helper = new Bixby.monitoring.PanSyncHelper(@bixby_graph)
