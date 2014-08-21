
Bixby.monitoring ||= {}

Bixby.monitoring.render_sparkline = (div, metric, opts) ->
  vals = metric.tuples()
  if !vals || vals.length == 0
    return

  opts ||= {}
  opts = _.extend({
    width: 150
    height: 35

    axes:
      x:
        drawAxis: false
        drawGrid: false
      y:
        drawAxis: false
        drawGrid: false

    stackedGraph:      true
    strokeWidth:       0
    strokeBorderWidth: 0
    colors:            [ "#468CC8"]
    fillAlpha:         1.0

    legend: "never"
    labels: [ "Date/Time", "v" ]
    showLabelsOnHighlight: false
    drawHighlightPointCallback: ->
      # noop

  }, opts)

  Bixby.monitoring.add_mouse_handlers(opts)
  Bixby.monitoring.add_touch_handlers(opts)

  ####
  # draw
  el = $(div).find(".graph")[0]
  g = new Dygraph(el, vals, opts)
  g._bixby_dragging = false # used to denote that we are in the middle of a click-drag operation
  g._bixby_metric = metric
  g._bixby_el = el
  g._bixby_mode = "pan"
  g._bixby_touch_enabled = false # default to disabled
  $(el).data({graph: g}) # store graph reference

  $(el).append("<span class='value'>")

  opts =
    highlightCallback: (e, x, pts, row, seriesName) ->
      Bixby.monitoring.handle_sparkline_hover(el, pts[0].canvasx, pts[0].yval)

    unhighlightCallback: (e) ->
      $(el).parents("div.wrapper").find("div.line.xline").hide()
      $(el).find("span.value").hide()

  g.updateOptions(opts, true)

  return g

Bixby.monitoring.handle_sparkline_hover = (el, pX, yVal) ->
  xline = $(el).parents("div.wrapper").find("div.line.xline")

  h = $(el).parents("table.metrics").height()
  x = $(el).position().left + pX
  xline.css({
    height: h-9+"px"
    top:    "9px"
    left:   x + "px"
  })
  xline.show()

  # show value text
  # calc offset
  opts = if pX > 50
    vr = $(el).offsetParent().width()-x-15
    { right: vr+"px", left: "auto" }
  else
    { left: pX+"px", right: "auto" }

  # show for every graph
  $(el).parents("div.wrapper").find("div.graph").each (i, el) ->
    gg = $(el).data("graph")
    yVal = Bixby.monitoring.find_value_near_x(gg, pX)
    yVal = Bixby.monitoring.format_value(yVal) if yVal != "n/a"
    $(el).find("span.value").text(yVal).css(opts).show()
