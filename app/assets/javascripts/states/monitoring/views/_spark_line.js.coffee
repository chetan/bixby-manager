namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.SparkLine extends Stark.Partial
    className: "sparkline"
    template: "monitoring/_spark_line"

    links:
      "td.metric_label a": [ "mon_hosts_metric", (e) -> { host: @host, metric: @metric } ]

    after_render: ->
      @metric.graph = Bixby.monitoring.render_sparkline(@$("div.sparkline").first(), @metric, {})
      return if !@metric.graph
      @$(".sparkline_bg").width(@metric.graph.getArea().w)
