namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.MetricDetail extends Stark.View
    el: "div.monitoring_content"
    template: "monitoring/metric_detail"
    render: ->
      super()
      s = ".metric[metric_id='" + @metric.id + "']"
      Bixby.monitoring.render_metric(s, @metric)
