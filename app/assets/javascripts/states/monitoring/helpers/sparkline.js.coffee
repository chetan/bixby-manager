
class Bixby.monitoring.Sparkline extends Bixby.monitoring.Graph

  render: (div, metric, opts) ->
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

    @set_y_ranges(opts, metric)
    @add_mouse_handlers(opts)
    @add_touch_handlers(opts)

    ####
    # draw
    el = $(div).find(".graph")
    @dygraph = g = new Dygraph(el[0], vals, opts)
    g._bixby_dragging = false # used to denote that we are in the middle of a click-drag operation
    g._bixby_metric = metric
    g._bixby_el = el[0]
    g._bixby_mode = "pan"
    el.data({graph: g}) # store graph reference

    el.append("<span class='value'>")

    opts =
      highlightCallback: (e, x, pts, row, seriesName) =>
        @show_tooltip(el, pts[0].canvasx, pts[0].yval)

      unhighlightCallback: (e) ->
        el.parents("div.wrapper").find("div.line.xline").hide()
        el.find("span.value").hide()

    g.updateOptions(opts, true)

    return g

  show_tooltip: (el, pX, yVal) ->
    xline = el.parents("div.wrapper").find("div.line.xline")

    h = el.parents("table.metrics").height()
    x = el.position().left + pX
    xline.css({
      height: h-9+"px"
      top:    "9px"
      left:   x + "px"
    })
    xline.show()

    # show value text
    # calc offset
    opts = if pX > 50
      r = el.width() - pX
      { right: r+"px", left: "auto" }
    else
      { left: pX+"px", right: "auto" }

    # show for every graph
    el.parents("div.wrapper").find("div.graph").each (i, el) ->
      el = $(el)
      gg = el.data("graph")
      return if !gg
      yVal = Bixby.monitoring.Graph.find_value_near_x(gg, pX)
      yVal = Bixby.monitoring.Graph.format_value(yVal) if yVal != "n/a"
      el.find("span.value").text(yVal).css(opts).show()
