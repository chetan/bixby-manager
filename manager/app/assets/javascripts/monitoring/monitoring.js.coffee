
jQuery ->

  Bixby.monitoring = {}
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
    console.log opts

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









  _bv = Bixby.view
  _vn = _bv.monitoring
  _bm = Bixby.model
  Bixby.app.add_state(
    class MonViewHostState extends Stark.State
      name: "mon_view_host" #  canonical name used for state transitions
                            #  e.g., it is referred to in events hash of other states

      url:  "monitoring/hosts/:host_id" #  match() pattern [optional]

      views:      [ _bv.PageLayout, _vn.Layout, _vn.MetricList ]
      no_redraw:  [ _bv.PageLayout, _vn.Layout ]
      models:     { host: _bm.Host, metrics: _bm.MetricList, checks: _bm.CheckList }

      events: {
        mon_hosts_resources_new: { models: [ _bm.Host ] }
        mon_hosts_resources_metric: { models: [ _bm.Host, _bm.Metric ]}
      }

      create_url: ->
        @url.replace /:host_id/, @host.id

      load_data: ->
        needed = []
        if ! @host?
          @host = new _bm.Host({ id: @params.host_id })
          needed.push @host

        if ! @checks?
          host_id = (@params? && @params.host_id) || @host.id
          @checks = new _bm.CheckList(host_id)
          needed.push @checks

        if ! @metrics?
          host_id = (@params? && @params.host_id) || @host.id
          @metrics = new _bm.MetricList(host_id)
          needed.push @metrics

        return needed

      activate: ->
        @app.trigger("nav:select_tab", "monitoring")
  )

  Bixby.app.add_state(
    class extends Stark.State

      name: "mon_hosts_resources_metric"
      url:  "monitoring/hosts/:host_id/metrics/:metric_id"

      create_url: ->
        @url.replace(/:host_id/, @host.id).replace(/:metric_id/, @metric.id)

      load_data: ->
        needed = []
        if ! @check?
          host_id = (@params? && @params.host_id) || @host.id
          @check = new _bm.Check(host_id)
          @check.metric_id = @params.metric_id
          needed.push @check

        if ! @metric?
          host_id = (@params? && @params.host_id) || @host.id
          @metric = new _bm.Metric(host_id)
          @metric.id = @params.metric_id
          needed.push @metric

        return needed


      views:      [ _bv.PageLayout, _vn.Layout, _vn.MetricDetail ]
      no_redraw:  [ _bv.PageLayout, _vn.Layout ]
      models:     { host: _bm.Host, check: _bm.Check, metric: _bm.Metric }
  )

  Bixby.app.add_state(
    class extends Stark.State
      name: "mon_hosts_resources_new"
      url:  "monitoring/hosts/:host_id/resources/new"

      views:      [ _bv.PageLayout, _vn.Layout, _vn.AddCommand ]
      no_redraw:  [ _bv.PageLayout, _vn.Layout ]
      models:     { host: _bm.Host, commands: _bm.MonitoringCommandList }

      create_url: ->
        @url.replace /:host_id/, @host.id

      load_data: ->
        needed = []
        if ! @host?
          @host = new _bm.Host({ id: @params.host_id })
          needed.push @host

        if ! @commands
          @commands = new _bm.MonitoringCommandList()
          needed.push @commands

        return needed
  )

  Bixby.app.add_state(
    class extends Stark.State
      name: "mon_hosts_resources_new_opts"
      views:      [ _bv.PageLayout, _vn.Layout, _vn.AddCommand, _vn.AddCommandOpts ]
      no_redraw:  [ _bv.PageLayout, _vn.Layout, _vn.AddCommand ]
      models:     { host: _bm.Host, commands: _bm.MonitoringCommandList }
      load_data: ->
        @spinner = new _bv.Spinner($("div.command_opts"))
        return @commands

      activate: ->
        @spinner.stop()

  )

