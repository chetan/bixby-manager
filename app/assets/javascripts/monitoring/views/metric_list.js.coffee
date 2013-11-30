namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.MetricList extends Stark.View
    el: "div.monitoring_content"
    template: "monitoring/resource_list"
    events: {
    }

    links: {

      # add resources/checks
      ".add_resource_link": [ "mon_hosts_resources_new", (el) ->
        return { host: @host }
        ]

      # add triggers on resources
      ".add_trigger_link": [ "mon_hosts_triggers_new", (el) ->
        return { host: @host, metrics: @metrics, checks: @checks }
        ]

      # metric detail page
      "div.metric a.metric": [ "mon_hosts_resources_metric", (el) ->
          check = @checks.get $(el).attr("check_id")
          metric = @metrics.get $(el).attr("metric_id")
          return { host: @host, check: check, metric: metric }
        ]
    }

    after_render: ->
      super()

      # render graphs into placeholder divs
      metrics = @metrics
      blockRedraw = false # used to block our drawCallback when synchronizing

      metrics.each (metric) ->
        s = ".check[check_id=" + metric.get("check_id") + "] .metric[metric_id='" + metric.id + "']"
        metric.graph = Bixby.monitoring.render_metric(s, metric)
        metric.graph._bixby_mode = "pan" # on panning in list view, no zoom

        # sync panning all graphs on page
        metric.graph.updateOptions({
          drawCallback: (g, isInitial) ->
            return if isInitial || blockRedraw
            blockRedraw = true
            range = g.xAxisRange();
            metrics.each (m) ->
              # redraw all graphs except the one which was panned
              if m.graph && m.graph != g
                m.graph.updateOptions({
                  dateWindow: range,
                })
            blockRedraw = false
          })

        # fired when panning is completed on the given graph
        # update all other graphs with more data
        #
        # @param [Dygraph] g        the graph which was just panned
        metric.graph._bixby_pan_complete = (g) ->
          metrics.each (m) ->
            if m.graph && m.graph != g
              Bixby.monitoring.load_more_data(m.graph, m)

      @
