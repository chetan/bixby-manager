
Bixby.monitoring ||= {}

# Render the given metric into the given selector
#
# div: parent div container for the metric, e.g., <div class="metric">
# metric: Metric model instance
# opts: extra opts for graph [optional]
# zoom_callback: fires after zoom is complete (data is loaded)
Bixby.monitoring.render_metric = (div, metric, opts, zoom_callback) ->

  format_value = (val) ->
    _.add_commas(_.str.sprintf("%0.2f", val))

  format_footer = (date, val, unit_label) ->
    date = new Date(date) if !_.isDate(date)
    date = strftime("%Y/%m/%d %H:%M:%S", date)
    val = format_value(val)
    _.str.sprintf("%s%s @ %s", val, unit_label, date)

  vals = metric.tuples()
  if !vals || vals.length == 0
    return

  # draw footer: "Last Value: 20.32%" or "Last Value: 3541 GB"
  footer = $(div).find(".footer")
  unit = metric.get("unit")
  unit_label = ""
  if unit?
    if unit == "%"
      unit_label = "%"
    else
      unit_label = " " + unit

  last_date   = vals[vals.length-1][0]
  last_val    = vals[vals.length-1][1]
  footer_text = format_footer(last_date, last_val, unit_label)
  footer.text(footer_text)

  # draw graph
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

  gc = $(div).find(".graph_container")
  # opts.width = gc.width()
  opts.height = gc.height()

  # Fix the y-axis value range
  opts.includeZero = true # always incldue zero on y-axis
  opts.yRangePad = 1 # just enough padding to show the top-most line
  range = metric.get_range()
  if unit == "%" && (!range? || range == "0..100")
    # use percentage range, unless overriden in range var
    opts.valueRange = [ 0, 100 ]

  else if range && (matches = range.match(/^(.*?)\.\.(.*?)$/))
    # use y-axis range as given in metric info
    opts.valueRange = [ parseFloat(matches[1]), parseFloat(matches[2]) ]

  ####
  # custom zoom/pan handling
  opts.interactionModel = _.clone(Dygraph.Interaction.defaultModel)

  # override mousedown to allow toggling pan mode
  opts.interactionModel.mousedown = (event, g, context) ->
    # Right-click should not initiate a zoom.
    if event.button && event.button == 2
      return

    g._bixby_dragging = true

    context.initializeMouseDown(event, g, context)

    if event.altKey || event.shiftKey || g._bixby_mode == "pan"
      if g._bixby_pan_start?
        g._bixby_pan_start()
      Dygraph.startPan(event, g, context)
    else
      Dygraph.startZoom(event, g, context)

  # override mouseup to load more data as we pan in either direction
  opts.interactionModel.mouseup = (event, g, context) ->
    g._bixby_dragging = false
    if context.isZooming
      Dygraph.endZoom(event, g, context)

    else if context.isPanning
      Dygraph.endPan(event, g, context)
      if g._bixby_pan_complete?
        g._bixby_pan_complete()


  ####
  # override touch events to make them optional
  opts.interactionModel.touchstart = (event, g, context) ->
    Dygraph.Interaction.startTouch(event, g, context) if g._bixby_touch_enabled

  opts.interactionModeltouchmove = (event, g, context) ->
    Dygraph.Interaction.moveTouch(event, g, context) if g._bixby_touch_enabled

  opts.interactionModeltouchend = (event, g, context) ->
    Dygraph.Interaction.endTouch(event, g, context) if g._bixby_touch_enabled


  ####
  # draw
  el = $(div).find(".graph")[0]
  g = new Dygraph(el, vals, opts)
  g._bixby_dragging = false # used to denote that we are in the middle of a click-drag operation
  g._bixby_metric = metric
  g._bixby_el = el
  g._bixby_mode = "zoom"
  g._bixby_touch_enabled = false # default to disabled

  # add a hidden point which we can use to draw a tooltip
  tooltip_anchor = Bixby.monitoring.create_tooltip(div)

  # set callbacks - have to do this after initial graph created
  opts = {
    highlightCallback: (e, x, pts, row, seriesName) ->
      text = format_footer(x, pts[0].yval, unit_label)
      footer.text(text)
      Bixby.monitoring.show_tooltip(g, div, tooltip_anchor, pts, text)

    unhighlightCallback: (e) ->
      footer.text(footer_text)

    # allow zooming in for more granular data (don't downsample)
    zoomCallback: (minX, maxX, yRanges) ->
      return if g._bixby_mode == "pan"

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

  }
  g.updateOptions(opts, true) # don't redraw here

  return g

# Create the tooltip
Bixby.monitoring.create_tooltip = (div) ->
  $(div).append("<div class='tooltip_anchor invisible' style='position:absolute;width:10px;height:10px;border:1px solid black;'></div>")
  tooltip_anchor = $(div).find("div.tooltip_anchor")
  tooltip_anchor.tooltip({trigger: "manual", container: div, placement: "left"})

  $(div).find("div.graph").mouseout (e) ->
    tooltip_anchor.tooltip("hide")

  return tooltip_anchor

# Show the tooltip - called from the graph highlightCallback
Bixby.monitoring.show_tooltip = (g, div, el, pts, text) ->
  if g._bixby_dragging
    el.tooltip("hide")
    return

  if el.data('bs.tooltip').options.title != text
    d = $(div).find(".graph").position()
    tx = d.left + pts[0].canvasx - 5 + "px"
    ty = d.top + pts[0].canvasy - 5 + "px"

    # bootstrap tooltip needs a little help with placement
    w = $(div).width()
    el.data('bs.tooltip').options.placement =
      if pts[0].canvasx < 200
        "right"
      else if w-pts[0].canvasx < 200
        "left"
      else
        "top"

    el.css({left: tx, top: ty})
    el.data('bs.tooltip').options.title = text
    el.tooltip("show")

Bixby.monitoring.load_more_data = (g) ->
  # check if we need more data
  [minX, maxX] = g.xAxisRange()
  [dMinX, dMaxX] = g.xAxisExtremes()
  start_diff = dMinX - minX
  end_diff = maxX - dMaxX

  startX = null
  if start_diff > 100000
    # panned passed the start of the graph (left)
    startX = minX
    endX = dMinX

  else if end_diff > 100000
    # panned passed the end of the graph (right)
    startX = dMaxX
    endX = maxX

    # don't send timestamps into the future
    now = new Date().getTime()
    if endX > now
      endX = now
    if endX - startX < 100000
      startX = null

  return if startX == null

  # TODO if we pan multiple times into the same area which we don't have data for
  #      maybe avoid panning again.. though it is possible to have gaps in the data
  #      (periods where the machine is off?)

  Bixby.monitoring.show_spinner(g)

  metric = g._bixby_metric
  query = metric.get("query")
  new_met = new Bixby.model.Metric({
    id: metric.id
    host_id: metric.get("metadata").host_id
    start: parseInt(startX / 1000)
    end: parseInt(endX / 1000)
    downsample: query.downsample || "5m-avg"
  })
  Backbone.multi_fetch [ new_met ], (err, results) ->
    # don't replace data... add on to existing data and sort by timestamp
    all_data = g.file_.concat(new_met.tuples()).sort (a,b) ->
      return a[0] - b[0]
    g.updateOptions({ file: all_data })
    Bixby.monitoring.hide_spinner(g)
