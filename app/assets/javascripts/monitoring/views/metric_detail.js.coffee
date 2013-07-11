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

      query = @metric.get("query")
      if query.downsample == "1h-avg"
        view.log "loading more granular data"
        new_met = new Bixby.model.Metric({
          id: view.metric.id
          host_id: view.metric.get("metadata")?.host_id
          start: query.start
          end: query.end
          downsample: "5m-avg"
        })
        Backbone.multi_fetch [ new_met ], (err, results) ->
          view.log "replacing old metric: ", view.metric
          view.log "with new metric: ", new_met
          view.metric = new_met
          view.redraw()

      @
