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
      @metric.graph = new Bixby.monitoring.Graph()
      if @metric.graph.render(@$("div.metric").first(), @metric)
        @metric.graph.dygraph._bixby_mode = "pan" # only panning in list view, no zoom
