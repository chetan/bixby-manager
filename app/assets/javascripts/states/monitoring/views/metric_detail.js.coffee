namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.MetricDetail extends Stark.View
    el: "div.monitoring_content"
    template: "monitoring/metric_detail"

    events:
      "click button.return_host": (e) ->
        @transition "mon_view_host", {host: @host}

      "click button#zoom": (e) ->
        @graph._bixby_mode = "zoom"
        @$("#pan").removeClass("active")

      "click button#pan": (e) ->
        @graph._bixby_mode = "pan"
        @$("#zoom").removeClass("active")

      "click .zoom_level a": (e) ->
        @update_zoom($(e.target).attr("data-level"))

    # Change the zoom level of the graph
    # Load data based on the time period selected, at the same sampling rate
    #
    # @param [String] level
    update_zoom: (level) ->
      period = 86400

      switch (@level = level)
        when "12hours"  then period /= 2; ds = "1m-avg"
        when "day"      then period *= 1; ds = "5m-avg"
        when "week"     then period *= 7; ds = "1h-avg"
        when "month"    then period *= 30; ds = "6h-avg"
        when "year"     then period *= 365; ds = "1d-avg"
        when "custom"   then return

      query = @metric.get("query")
      range_end = query.end || (@graph.xAxisRange()[1]/1000)
      range_start = range_end - period

      view = @
      new_met = new Bixby.model.Metric({
        id: view.metric.id
        host_id: view.metric.get("metadata")?.host_id
        start: range_start
        end: range_end
        downsample: ds
      })
      Backbone.multi_fetch [ new_met ], (err, results) ->
        view.metric = new_met
        view.redraw()


    dispose: ->
      super()
      $(window).unbind("resize")
      @graph.destroy() if @graph

    after_render: ->
      super()

      query = @metric.get("query")

      # set defaults
      @$("button#zoom").addClass("active")
      if @level
        zoom = @level
      else if query.start == 0 && query.end == 0
        zoom = "day"

      view = @
      @$("div.zoom_level a").each (i, el) ->
        if $(el).attr("data-level") == zoom
          view.$("div.zoom_level button .text").text($(el).text())

      @graph = Bixby.monitoring.render_metric(@$("div.metric"), @metric)
      @sync_helper = new Bixby.monitoring.PanSyncHelper(@graph)

      if @level
        # make sure we show the entire date range
        d = @graph.xAxisRange()
        if d[0] > query.start*1000
          d[0] = query.start*1000
          @graph.updateOptions({ dateWindow: d })

      # on first load, fetch more data
      # specifically when moving from list view which has less granular (1h-avg) data
      if !@level && query.downsample == "1h-avg"
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
