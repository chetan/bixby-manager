
Bixby.monitoring = {}

# s: CSS selector root for locating graph, ex:
#
#   s = ".check[check_id=" + metric.get("check_id") + "] .metric[metric_id='" + metric.id + "']"
#
# metric: Metric model instance
Bixby.monitoring.render_metric = (s, metric) ->

  el = $(s + " .graph")[0]

  data = metric.get("data")
  if !data
    return

  # draw footer
  footer = $(s + " .footer")
  unit = ""
  if metric.unit?
    if metric.unit != "%"
      unit = " " + metric.unit
    else
      unit = "%"
  footer_text = sprintf("Last Value: %0.2f%s", data[data.length-1].y, unit)
  footer.text(footer_text)

  vals = _.map data, (v) ->
    [ new Date(v.x * 1000), v.y ]

  opts = {
    labels: [ "Date/Time", "v" ]
    strokeWidth: 2
    showLabelsOnHighlight: false
    legend: "never"
  }

  gc = $(s + " .graph_container")
  opts.width = gc.width()
  opts.height = gc.height()

  if metric.unit == "%"
    # set range if known
    opts.valueRange = [ 0, 100 ]

  # draw
  g = new Dygraph(el, vals, opts)

  # set callbacks
  xOptView = g.optionsViewForAxis_('x');
  xvf = xOptView('valueFormatter');
  opts = {
    highlightCallback: (e, x, pts, row) ->
      date = xvf(x, xOptView, "", g) + ", " + sprintf("val = %0.2f%s", pts[0].yval, unit)
      footer.text(date)

    unhighlightCallback: (e) ->
      footer.text(footer_text)

    # allow zooming in for more granular data (don't downsample)
    zoomCallback: (minX, maxX, yRanges) ->
      if g.is_granular
        if minX == g.rawData_[0][0] && maxX == g.rawData_[g.rawData_.length-1][0]
          g.updateOptions({ file: g.less_granular })
          g.less_granular = null
          g.is_granular = null
        return

      r = (maxX - minX) / 1000
      if r < 43200
        # load more granular data
        g.less_granular = g.file_
        g.is_granular = true
        new_met = new Bixby.model.Metric({
          id: metric.id
          host_id: metric.get("metadata").host_id
          start: parseInt(minX / 1000)
          end: parseInt(maxX / 1000)
        })
        Backbone.multi_fetch [ new_met ], (err, results) ->
          vals = _.map new_met.get("data"), (v) ->
            [ new Date(v.x * 1000), v.y ]
          g.updateOptions({ file: vals })

  }
  g.updateOptions(opts);


# just for reference, rendering using rickshaw
Bixby.monitoring.render_with_rickshaw = (s, metric) ->
  super() # render()

  # display graphs
  @resources.each (res) ->
    metrics = res.get("metrics");
    _.each metrics, (val, key) ->
      s = ".resource[resource_id=" + res.id + "] .metric[metric='" + key + "']"
      el = $(s + " .graph")[0]

      graph = new Rickshaw.Graph( {
        element: el,
        width: 300,
        height: 100,
        renderer: 'line',
        series: [{
          # name: "foo",
          color: 'steelblue',
          data: val.vals
        }]
      } );
      x_axis = new Rickshaw.Graph.Axis.Time({
        graph: graph,
        # element: $(s + ' .x_axis')[0]
      });
      y_axis = new Rickshaw.Graph.Axis.Y({
        graph: graph,
        orientation: 'left',
        # tickFormat: Rickshaw.Fixtures.Number.formatKMBT,
        element: $(s + ' .y_axis')[0],
      });
      hoverDetail = new Rickshaw.Graph.HoverDetail({
        graph: graph
      });
      graph.render();
      $(s + " .footer").text(sprintf("Last Value: %0.2f", val.vals[val.vals.length-1].y));



