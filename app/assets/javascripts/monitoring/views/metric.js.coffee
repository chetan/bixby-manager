namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.Metric extends Stark.Partial

    className: "metric"
    template: "monitoring/_metric"

    after_render: ->
      @metric.graph = Bixby.monitoring.render_metric(@$el, @metric, {})
      return if !@metric.graph

      @metric.graph._bixby_mode = "pan" # only panning in list view, no zoom
      # @metric.graph._bixby_show_spinner = true # use a spinner in list view
