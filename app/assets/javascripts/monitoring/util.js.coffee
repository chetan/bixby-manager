
Bixby.monitoring = {}

# Render the given metric into the given selector
#
# s: CSS selector root for locating graph, ex:
#
#   s = ".check[check_id=" + metric.get("check_id") + "] .metric[metric_id='" + metric.id + "']"
#
# metric: Metric model instance
# opts: extra opts for graph [optional]
Bixby.monitoring.render_metric = (s, metric, opts) ->

  el = $(s + " .graph")[0]

  vals = metric.tuples()
  if !vals || vals.length == 0
    return

  # draw footer
  footer = $(s + " .footer")
  unit = ""
  if metric.unit?
    if metric.unit != "%"
      unit = " " + metric.unit
    else
      unit = "%"
  last_val = vals[vals.length-1][1]
  footer_text = sprintf("Last Value: %0.2f%s", last_val, unit)
  footer.text(footer_text)

  # draw graph
  opts ||= {}
  opts = _.extend({
    labels: [ "Date/Time", "v" ]
    strokeWidth: 2
    showLabelsOnHighlight: false
    legend: "never"
  }, opts)

  gc = $(s + " .graph_container")
  opts.width = gc.width()
  opts.height = gc.height()

  if metric.unit == "%"
    # set range if known
    opts.valueRange = [ 0, 100 ]

  ####
  # custom zoom/pan handling
  opts.interactionModel = _.clone(Dygraph.Interaction.defaultModel)

  # override mousedown to allow toggling pan mode
  opts.interactionModel.mousedown = (event, g, context) ->
    # Right-click should not initiate a zoom.
    if event.button && event.button == 2
      return

    context.initializeMouseDown(event, g, context)

    if event.altKey || event.shiftKey || g._bixby_mode == "pan"
      Dygraph.startPan(event, g, context)
    else
      Dygraph.startZoom(event, g, context)

  # override mouseup to load more data as we pan in either direction
  opts.interactionModel.mouseup = (event, g, context) ->
    if context.isZooming
      Dygraph.endZoom(event, g, context)

    else if context.isPanning
      Dygraph.endPan(event, g, context)
      Bixby.monitoring.load_more_data(g, metric)
      if g._bixby_pan_complete?
        # fire custom callback
        g._bixby_pan_complete(g)


  ####
  # draw
  g = new Dygraph(el, vals, opts)
  g._bixby_el = el
  g._bixby_mode = "zoom"

  # set callbacks - have to do this after initial graph created
  xOptView = g.optionsViewForAxis_('x')
  xvf = xOptView('valueFormatter')
  opts = {
    highlightCallback: (e, x, pts, row) ->
      date = xvf(x, xOptView, "", g) + ", " + sprintf("val = %0.2f%s", pts[0].yval, unit)
      footer.text(date)

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
        return

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

Bixby.monitoring.load_more_data = (g, metric) ->
  # check if we need more data
  [minX, maxX] = g.xAxisRange()
  [dMinX, dMaxX] = g.xAxisExtremes()
  start_diff = dMinX - minX
  end_diff = maxX - dMaxX

  startX = null
  if start_diff > 100000
    startX = minX
    endX = dMinX

  else if end_diff > 100000
    startX = dMaxX
    endX = maxX

    # don't send timestamps into the future
    now = new Date().getTime()
    if endX > now
      endX = now
    if endX - startX < 100000
      startX = null

  return if startX == null

  query = metric.get("query")
  new_met = new Bixby.model.Metric({
    id: metric.id
    host_id: metric.get("metadata").host_id
    start: parseInt(startX / 1000)
    end: parseInt(endX / 1000)
    downsample: query.downsample || "5m-avg"
  })
  Backbone.multi_fetch [ new_met ], (err, results) ->
    # don't replace data... add on to existing data
    all_data = g.file_.concat(new_met.tuples()).sort (a,b) ->
      return a[0] - b[0]
    g.updateOptions({ file: all_data })
