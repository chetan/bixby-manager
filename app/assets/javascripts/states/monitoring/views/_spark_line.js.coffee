namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.SparkLine extends Stark.Partial
    className: "sparkline"
    template: "monitoring/_spark_line"

    links:
      "td.metric_label a": [ "mon_hosts_metric", (e) -> { host: @host, metric: @metric } ]

    after_render: ->
      @metric.graph = new Bixby.monitoring.Sparkline()
      if dygraph = @metric.graph.render(@$("div.sparkline").first(), @metric)
        @$(".sparkline_bg").width(dygraph.getArea().w)
