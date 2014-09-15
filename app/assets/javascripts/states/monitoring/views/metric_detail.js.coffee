namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.MetricDetail extends Stark.View
    el: "div.monitoring_content"
    template: "monitoring/metric_detail"

    ui:
      live:
        button: "button#live"
        icon: "button#live span"

    links:
      "a.check":      [ "mon_hosts_check", -> { host: @host, check: @check } ]
      "a.fullscreen": [ "metric_fullscreen", -> { host: @host, check: @check, metric: @metric } ]

    events:
      "click button#create_trigger": (e) ->
        @transition "mon_hosts_triggers_new", { host: @host, for_check: @check, for_metric: @metric }

      "click button.return_host": (e) ->
        @transition "mon_view_host", {host: @host}

      "click label.zoom": (e) ->
        @graph._bixby_mode = "zoom"
        @$("div.graph").addClass("zoom").removeClass("pan")

      "click label.pan": (e) ->
        @graph._bixby_mode = "pan"
        @$("div.graph").addClass("pan").removeClass("zoom")

      "click .zoom_level a": (e) ->
        @update_zoom($(e.target).attr("data-level"))

      "click button#reset": (e) ->
        @graph.resetZoom()

      "click live.button": (e) ->
        @ui.live.button.toggleClass("active")
        @update_live()

      "mouseenter live.button": (e) ->
        if @ui.live.button.hasClass("active")
          @ui.live.icon.html( _.icon("pause") )

      "mouseleave live.button": (e) ->
        if @ui.live.button.hasClass("active")
          @update_live_icon()

    update_live: ->
      @update_live_icon()
      if @ui.live.button.hasClass("active")
        @bixby_graph.enable_live_update()
      else
        @bixby_graph.disable_live_update()

    update_live_icon: ->
      html = if @ui.live.button.hasClass("active")
        _.icon("refresh", "fa-spin")
      else
        _.icon("play")
      @ui.live.icon.html(html)

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

      # TODO spinner?
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

    # set zoom level menu text
    set_zoom_level_label: (level) ->
      view = @
      @$("div.zoom_level a").each (i, el) ->
        if $(el).attr("data-level") == level
          view.$("div.zoom_level button .text").text( $(el).text() )

    # Create help popover
    display_help: ->
      if help = @check.command().help()
        " " + @help(help)
      else
        ""

    dispose: ->
      super()
      $(window).unbind("resize")
      @graph.destroy() if @graph

    after_render: ->
      super()

      query = @metric.get("query")

      # set defaults
      @$("div.graph").addClass("zoom")
      if @level
        zoom = @level
      else if query.start == 0 && query.end == 0
        zoom = "day"
      @set_zoom_level_label(zoom)

      view = @

      zoom_callback = (reset) ->
        if reset
          view.set_zoom_level_label(zoom)
          view.$("button#reset").addClass("disabled")
          return

        view.$("button#reset").removeClass("disabled")
        view.$("div.zoom_level button .text").text("Custom")

        # disable live updates if not near right edge (within 30 minutes)
        [minX, maxX] = view.graph.xAxisRange()
        [dMinX, dMaxX] = view.graph.xAxisExtremes()
        if dMaxX - maxX > 1800000
          view.ui.live.button.removeClass("active")
          view.update_live()

      @bixby_graph = new Bixby.monitoring.Graph()
      @bixby_graph.touch_enabled = true
      if @graph = @bixby_graph.render(@$("div.metric"), @metric, {}, zoom_callback)
        @sync_helper = new Bixby.monitoring.PanSyncHelper(@bixby_graph)

      # enable live data
      @ui.live.button.addClass("active")
      @update_live()

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
