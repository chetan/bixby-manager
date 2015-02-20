
Bixby.monitoring ||= {}

Bixby.monitoring.Graph = class

  # Callback which fires after zoom action is complete (ranges updated but before new data is loaded)
  on_zoom_complete: null

  # Callback which fires after pan action is complete. Only fires on the original graph which was panned.
  on_pan_complete: null

  @find_value_near_x: (g, pX) ->
    if coord = @find_nearest_coord(g, pX)
      return coord.point[1]
    else
      return "n/a"

  @find_nearest_coord: (g, pX) ->

    if g.findClosestRow?
      # use builtin method
      i = g.findClosestRow(pX)
      if i >= 0
        return {point: g.rawData_[i], idx: i}
      return null

    # use our own impl (since the previous method is private and may go away)
    xVal = g.toDataXCoord(pX)
    found_pair = null
    d = null
    _.each g.rawData_, (row, i) ->
      if row[0] == xVal
        found_pair = {point: row, idx: i}
        return

      dx = Math.abs(row[0]-xVal)
      if !d || dx < d
        d = dx
        found_pair = {point: row, idx: i}

    return found_pair

  find_value_near_x: (pX) ->
    Bixby.monitoring.Graph.find_value_near_x(@dygraph, pX)

  find_nearest_coord: (pX) ->
    Bixby.monitoring.Graph.find_nearest_coord(@dygraph, pX)

  @format_value: (val) ->
    _.add_commas(_.str.sprintf("%0.2f", val))

  # Render the given metric into the given selector
  #
  # div: parent div container for the metric, e.g., <div class="metric">
  # metric: Metric model instance
  # opts: extra opts for graph [optional]
  render: (div, metric, opts) ->
    vals = metric.tuples()
    if !vals || vals.length == 0
      return

    # locate our container elements
    @el = el = $(div).find(".graph")
    @gc = el.parents("div.graph_container")

    # dygraph options
    opts ||= {}
    opts = _.extend({
      labels: [ "Date/Time", "v" ]
      # strokeWidth: 3
      stackedGraph: true
      showLabelsOnHighlight: false

      highlightCircleSize: 2
      strokeWidth: 3
      strokeBorderWidth: 0 # border/padding between graph line and stacked area/fill

      highlightSeriesOpts:
        strokeWidth: 3
        strokeBorderWidth: 0
        highlightCircleSize: 5,

      colors: [ "#428bca"]

      legend: "never"
    }, opts)

    # set y-axis label, if needed
    name = metric.display_name()
    if !opts._disable_ylabel && name? && name.length > 0
      opts.ylabel = name
    else if opts._disable_ylabel
      opts.axisLabelWidth = 30 # to get rid of padding for label
    else
      opts.axisLabelWidth = 20

    @set_y_ranges(opts, metric)
    @add_mouse_handlers(opts)
    @add_touch_handlers(opts)

    ####
    # draw
    @dygraph = g = new Dygraph(el[0], vals, opts)

    # TODO move variables into Graph class?
    @metric = g._bixby_metric = metric
    g._bixby_el = el[0]

    g._bixby_dragging = false # used to denote that we are in the middle of a click-drag operation
    g._bixby_mode = "zoom" # whether a click+drag should initiate a "zoom" or "pan"
    g._bixby_is_panning = false # flag to denote an active pan operation
    g._bixby_is_zooming = false

    g._bixby_show_spinner = false # when true, a spinner will be displayed while loading data

    @footer = $(div).find(".footer")
    @update_footer_text(true)
    @create_tooltip()

    # set callbacks - have to do this after initial graph created
    opts =
      highlightCallback: (e, x, pts, row, seriesName) =>
        if g._bixby_dragging
          @update_footer_text(true)
        else
          text = metric.format_value(pts[0].yval, x)
          @footer.text("Highlighted Value: " + text)

        @show_tooltip(g, el, pts[0].canvasx, e.pageY, text)

      unhighlightCallback: (e) =>
        @footer.text(@footer_text)

      # allow zooming in for more granular data (don't downsample)
      zoomCallback: (minX, maxX, yRanges) =>
        return if g._bixby_mode == "pan"

        # always hide tooltip on zoom-complete
        @hide_tooltip()

        if g._bixby_is_granular
          # already showing granular data, see if zoom was reset and show less granular data
          [dMinX, dMaxX] = g.xAxisExtremes()
          if minX == dMinX && maxX == dMaxX
            g.updateOptions({ file: g._bixby_less_granular })
            g._bixby_less_granular = null
            g._bixby_is_granular = null
            @on_zoom_complete? && @on_zoom_complete(true)
          return

        @on_zoom_complete? && @on_zoom_complete(false)

        r = (maxX - minX) / 1000
        if r < 43200
          # load more granular data, since we are looking at less than 12 hours of data
          g._bixby_less_granular = g.file_
          g._bixby_is_granular = true
          metric.get("query").downsample = "1m-avg"
          @fetch_more_data(minX, maxX, null, true)

    g.updateOptions(opts, true) # don't redraw here
    return g

  # Cleanup
  dispose: ->
    @disable_live_update()
    @dygraph.destroy() if @dygraph

  # Fix the y-axis value range
  set_y_ranges: (opts, metric) ->
    opts.includeZero = true # always incldue zero on y-axis
    opts.yRangePad = 1 # just enough padding to show the top-most line

    unit  = metric.get("unit")
    range = metric.get_range()
    if unit == "%" && (!range? || range == "0..100")
      # use percentage range, unless overriden in range var
      opts.valueRange = [ 0, 100 ]

    else if range && (matches = range.match(/^(.*?)\.\.(.*?)$/))
      # use y-axis range as given in metric info
      opts.valueRange = [ parseFloat(matches[1]), parseFloat(matches[2]) ]

  # Update the footer with the last value
  update_footer_text: (force) ->
    if !@dygraph || (!@footer.text().match(/Last Value/) && !force)
      return # skip updating because we are probably highlighting

    pair         = @dygraph.rawData_[@dygraph.rawData_.length-1]
    last_date    = pair[0]
    last_val     = pair[1]
    @footer_text = "Last Value: " + @metric.format_value(last_val, last_date)
    @footer.text(@footer_text)

  # Enable live updating
  enable_live_update: ->
    @live_data = true
    @fetch_live_data()

  # Disable live updating
  disable_live_update: ->
    @live_data = false
    clearTimeout(@live_data_id) if @live_data_id
    @live_data_id = null

  # Enable a timer to fetch new data every 60 sec
  # TODO: maintain the date range window (e.g., if 24 hours, old points should shift out as new ones are loaded)
  fetch_live_data: ->
    @live_data_id = _.delayR 60000, =>
      return if !@live_data
      [dMinX, dMaxX] = @dygraph.xAxisExtremes()
      @fetch_more_data(dMaxX+1000, dMaxX + 120000, @fetch_live_data)  # ask for another 2min of data

  # Fetch data for the given period and append it to this chart's dataset
  #
  # @param [Number] startX        start time in milliseconds
  # @param [Number] endX          end time in milliseconds
  # @param [Function] cb          [Optional] callback to fire after data has been fetched and the graph has been updated
  fetch_more_data: (startX, endX, cb, replace) ->
    @show_spinner()

    g = @dygraph
    metric = g._bixby_metric
    new_met = new Bixby.model.Metric({
      id: metric.id
      host_id: metric.get("metadata").host_id
      start: parseInt(startX / 1000)
      end: parseInt(endX / 1000)
      downsample: metric.get("query").downsample || "5m-avg"
    })
    Backbone.multi_fetch [ new_met ], (err, results) =>
      if replace
        g.updateOptions({ file: new_met.tuples() })
      else
        # don't replace data... add on to existing data and sort by timestamp
        all_data = g.file_.concat(new_met.tuples()).sort (a,b) ->
          return a[0] - b[0]
        g.updateOptions({ file: all_data })

      @update_footer_text()
      @hide_spinner()
      if cb?
        cb.call(@)
