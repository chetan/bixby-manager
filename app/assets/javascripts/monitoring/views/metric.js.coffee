namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.Metric extends Stark.Partial

    className: "metric"
    template: "monitoring/_metric"

    after_render: ->
      @metric.graph = Bixby.monitoring.render_metric(@$el, @metric, {})
      @metric.graph._bixby_mode = "pan" if @metric.graph # only panning in list view, no zoom
