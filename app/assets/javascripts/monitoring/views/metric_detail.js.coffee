namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.MetricDetail extends Stark.View
    el: "div.monitoring_content"
    template: "monitoring/metric_detail"

    events: {
      "click button#zoom": (e) ->
        @graph._bixby_mode = "zoom"

      "click button#history": (e) ->
        @graph._bixby_mode = "pan"
    }


    dispose: ->
      super()
      $(window).unbind("resize")

    render: ->
      super()
      @$("button#zoom").addClass("active")
      s = ".metric[metric_id='" + @metric.id + "']"
      @graph = Bixby.monitoring.render_metric(s, @metric)
      @graph.updateOptions({ interactionModel: {} })

      view = @
      $(window).resize _.debounceR 200, ->
        view.log "redrawing graph view on resize"
        view.redraw()

      query = @metric.get("query")
      if query.downsample == "1h-avg"
        new_met = new Bixby.model.Metric({
          id: view.metric.id
          host_id: view.metric.get("metadata")?.host_id
          start: query.start
          end: query.end
          downsample: "5m-avg"
        })
        Backbone.multi_fetch [ new_met ], (err, results) ->
          view.metric = new_met
          view.redraw()

      @
