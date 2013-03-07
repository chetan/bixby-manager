namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.MetricDetail extends Stark.View
    el: "div.monitoring_content"
    template: "monitoring/metric_detail"

    dispose: ->
      super()
      $(window).unbind("resize");

    render: ->
      super()
      s = ".metric[metric_id='" + @metric.id + "']"
      Bixby.monitoring.render_metric(s, @metric)
      view = @
      $(window).resize _.debounceR 200, ->
        view.redraw()
