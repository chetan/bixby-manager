namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.Metric extends Stark.Partial

    className: "metric"
    template: "monitoring/_metric"

    metric_label: null # set this to use a custom label

    links:
      "div.metric a.metric": [ "mon_hosts_metric", (el) ->
          return { host: @host, check: @check, metric: @metric }
        ]

    after_render: ->
      @metric.graph = Bixby.monitoring.render_metric(@$el, @metric, {})
      return if !@metric.graph

      @metric.graph._bixby_mode = "pan" # only panning in list view, no zoom
      # @metric.graph._bixby_show_spinner = true # use a spinner in list view
