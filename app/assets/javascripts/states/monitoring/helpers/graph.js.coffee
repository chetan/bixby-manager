
Bixby.monitoring ||= {}

Bixby.monitoring.Graph = class

  @find_value_near_x: (g, pX) ->
    if pair = @find_nearest_coord(g, pX)
      return pair[1]
    else
      return "n/a"

  @find_nearest_coord: (g, pX) ->

    if g.findClosestRow?
      # use builtin method
      i = g.findClosestRow(pX)
      if i >= 0
        return g.rawData_[i]
      return null

    # use our own approximation
    xVal = g.toDataXCoord(pX)
    found_pair = null
    d = null
    _.each g.rawData_, (data) ->
      if data[0] == xVal
        found_pair = data
        return

      dx = Math.abs(data[0]-xVal)
      if !d || dx < d
        d = dx
        found_pair = data

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
  # zoom_callback: fires after zoom is complete (data is loaded)
  render: (div, metric, opts, zoom_callback) ->
    vals = metric.tuples()
    if !vals || vals.length == 0
      return

    # locate our container elements
    @el = el = $(div).find(".graph")
    @gc = el.parents("div.graph_container")

    # set initial footer text
    last_date   = vals[vals.length-1][0]
    last_val    = vals[vals.length-1][1]
    footer      = $(div).find(".footer")
    footer_text = metric.format_value(last_val, last_date) # referenced later in unhighlightCallback
    footer.text(footer_text)

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

    @create_tooltip()

    # set callbacks - have to do this after initial graph created
    opts =
      highlightCallback: (e, x, pts, row, seriesName) =>
        text = metric.format_value(pts[0].yval, x)
        footer.text(text)
        @show_tooltip(g, el, pts[0].canvasx, e.pageY, text)

      unhighlightCallback: (e) =>
        footer.text(footer_text)

      # allow zooming in for more granular data (don't downsample)
      zoomCallback: (minX, maxX, yRanges) =>
        return if g._bixby_mode == "pan"

        # always hide tooltip on zoom-complete
        @hide_tooltip()

        if g._bixby_is_granular
          # already showing granular data, see if zoom was reset and show less granular data
          if minX == g.rawData_[0][0] && maxX == g.rawData_[g.rawData_.length-1][0]
            g.updateOptions({ file: g._bixby_less_granular })
            g._bixby_less_granular = null
            g._bixby_is_granular = null
            zoom_callback? && zoom_callback(true)
          return

        zoom_callback? && zoom_callback()

        r = (maxX - minX) / 1000
        if r < 43200
          # load more granular data, since we are looking at less than 12 hours of data
          g._bixby_less_granular = g.file_
          g._bixby_is_granular = true
          new_met = new Bixby.model.Metric({
            id: metric.id
            host_id: metric.get("metadata").host_id
            start: parseInt(minX / 1000)
            end: parseInt(maxX / 1000)
            downsample: "1m-avg"
          })
          Backbone.multi_fetch [ new_met ], (err, results) ->
            metric.set({query: new_met.get("query")})
            g.updateOptions({ file: new_met.tuples() })

    g.updateOptions(opts, true) # don't redraw here
    return g

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

  fetch_more_data: (startX, endX) ->
    # TODO if we pan multiple times into the same area which we don't have data for
    #      maybe avoid panning again.. though it is possible to have gaps in the data
    #      (periods where the machine is off?)

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
      # don't replace data... add on to existing data and sort by timestamp
      all_data = g.file_.concat(new_met.tuples()).sort (a,b) ->
        return a[0] - b[0]
      g.updateOptions({ file: all_data })
      @hide_spinner()
