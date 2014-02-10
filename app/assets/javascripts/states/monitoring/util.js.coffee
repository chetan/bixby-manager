
Bixby.monitoring = {}

# Wraps all functionality related to loading more data when panning the graph
class Bixby.monitoring.PanSyncHelper

  constructor: (@graphs) ->
    @graphs = [ @graphs ] if !_.isArray(@graphs)
    @context = {}
    _.eachR @, @graphs, (g) -> @setup_pan_handler(@graphs, g, @context)
    @setup_document_handlers(@graphs, @context)


  # Document events
  #
  # @param [Array<Dygraph>] graphs
  # @param [Hash] context               for holding special state flags
  setup_document_handlers: (graphs, context) ->
    $(document).on "mouseup", (e) ->
      return if !context._last_click? || e.target.tagName.toUpperCase() == "CANVAS"
      g = context._last_click
      g._bixby_pan_complete() if g?

    # attach pan scroll helper
    $("div.graph").appear()
    $(document.body).on "appear", "div.graph", _.debounceR 100, (e, appeared) ->
      # loop through appeared elements, match up with metric graph elements, and load data if necessary
      _.each appeared, (el) ->
        _.each graphs, (graph) ->
          return if !graph
          if graph._bixby_el == el && graph._bixby_needs_more_data == true
            graph._bixby_needs_more_data = false
            Bixby.monitoring.load_more_data(graph)


  # Pan events
  #
  # @param [Array<Dygraph>] graphs
  # @param [Dygraph] graph
  # @param [Hash] context               for holding special state flags
  setup_pan_handler: (graphs, graph, context) ->

    return if !graph?

    # sync panning all graphs on page
    opts = {
      drawCallback: (g, isInitial) ->
        # only process this callback after the initial draw and
        # only for the graph which was clicked
        return if isInitial || context._blockRedraw || context._last_click != g
        context._blockRedraw = true

        range = g.xAxisRange()
        _.each graphs, (graph) ->
          # redraw all graphs except the one which was panned (g)
          if graph && graph != g
            if _.isScrolledIntoView(graph._bixby_el, true)
              graph.updateOptions({
                dateWindow: range,
              })
            else
              # defer range update til it comes into view
              graph._bixby_update_range = range

        context._blockRedraw = false
      }

    graph.updateOptions(opts)

    graph._bixby_pan_start = ->
      context._last_click = @ # store it so we can use it to filter redraws
      context._last_click_range = @xAxisRange()

    # fired when panning is completed on the given graph
    # update all other graphs with more data
    #
    # @param [Dygraph] g        the graph which was just panned
    graph._bixby_pan_complete = ->
      # bail if X range did not change
      return if @xAxisRange()[0] == context._last_click_range[0]
      context._last_click = context._last_click_range = null

      _.eachR @, graphs, (graph) ->
        if graph
          if _.isScrolledIntoView(graph._bixby_el, true)
            Bixby.monitoring.load_more_data(graph)
          else
            # defer loading of graphs that aren't visible
            graph._bixby_needs_more_data = true

        # update x-axis
        if graph && graph._bixby_update_range?
          graph.updateOptions({
            dateWindow: graph._bixby_update_range,
          })
          graph._bixby_update_range = null


# Render the given metric into the given selector
#
# div: parent div container for the metric, e.g., <div class="metric">
# metric: Metric model instance
# opts: extra opts for graph [optional]
Bixby.monitoring.render_metric = (div, metric, opts) ->

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
  last_val = vals[vals.length-1][1]
  footer_text = _.str.sprintf("Last Value: %0.2f%s", last_val, unit_label)
  footer.text(footer_text)

  # draw graph
  opts ||= {}
  opts = _.extend({
    labels: [ "Date/Time", "v" ]
    strokeWidth: 2
    showLabelsOnHighlight: false
    legend: "never"
  }, opts)

  gc = $(div).find(".graph_container")
  opts.width = gc.width()
  opts.height = gc.height()

  # Fix the y-axis value range
  opts.includeZero = true # always incldue zero on y-axis
  range = metric.get("range")
  if unit == "%" && (!range? || range == "0..100")
    # use percentage range, unless overriden in range var
    opts.valueRange = [ 0, 100 ]
    opts.yRangePad = 1

  else if metric.get("range") && (matches = metric.get("range").match(/\.\./))
    # use y-axis range as given in metric info
    opts.valueRange = [ matches[1], matches[2] ]

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
      if g._bixby_pan_start?
        g._bixby_pan_start()
      Dygraph.startPan(event, g, context)
    else
      Dygraph.startZoom(event, g, context)

  # override mouseup to load more data as we pan in either direction
  opts.interactionModel.mouseup = (event, g, context) ->
    if context.isZooming
      Dygraph.endZoom(event, g, context)

    else if context.isPanning
      Dygraph.endPan(event, g, context)
      if g._bixby_pan_complete?
        g._bixby_pan_complete()


  ####
  # draw
  el = $(div).find(".graph")[0]
  g = new Dygraph(el, vals, opts)
  g._bixby_metric = metric
  g._bixby_el = el
  g._bixby_mode = "zoom"

  # set callbacks - have to do this after initial graph created
  xOptView = g.optionsViewForAxis_('x')
  xvf = xOptView('valueFormatter')
  opts = {
    highlightCallback: (e, x, pts, row) ->
      date = xvf(x, xOptView, "", g) + ", " + _.str.sprintf("val = %0.2f%s", pts[0].yval, unit_label)
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

# Dim the graph and show a spinner
Bixby.monitoring.show_spinner = (g) ->
  return if !g._bixby_show_spinner
  el = g._bixby_el
  _.dim(el)

  spin_opts = {
    lines:     11,
    length:    9,
    width:     4,
    radius:    8,
    top:       0-$(el).height()/2 + "px",
    left:      $(el).width()/2-4 + "px"
  }
  g._bixby_spinner = new Bixby.view.Spinner($(el).parent(), spin_opts)

# Undim and hide the spinner
Bixby.monitoring.hide_spinner = (g, spinner) ->
  return if !g._bixby_spinner?
  g._bixby_spinner.stop()
  _.undim(g._bixby_el)
