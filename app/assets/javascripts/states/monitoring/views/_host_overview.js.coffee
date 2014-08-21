namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.HostOverview extends Stark.Partial
    className: "host_overview"
    template: "monitoring/_host_overview"

    links:
      "h3 a": [ "mon_view_host", (el) -> { host: @host, metrics: (new _bm.HostSummaryMetricList()).reset(@metrics) } ]

    events:
      "mousemove td.sparkline": (e) ->
        return if !$(e.target).hasClass("sparkline")

        x = e.clientX - @$("div.graph").first().offset().left

        # don't draw the line outside of actual graph boundaries
        oX = @$("div.graph").offsetParent().offset().left
        gX = @$("div.graph").offset().left
        gW = @metrics[0].graph.getArea().w
        upperBound = gW
        if x < 0
          x = 0
        else if x > upperBound + 15
          @$("div.line.xline").hide()
          return
        else if x > upperBound
          x = upperBound

        Bixby.monitoring.handle_sparkline_hover(@$("div.graph")[0], x)

      "mouseout td.sparkline": (e) ->
        @$("div.line.xline").hide()
        @$("span.value").hide()


    # Display the metrics for the given keys
    display_metrics: ->
      keys = [ "cpu.loadavg.5m", "cpu.usage.user", "cpu.usage.system", "mem.usage", "fs.disk.usage" ]
      _.each keys, (key) =>
        _.each @metrics, (metric) =>
          return if metric.get("key") != key
          # uses a custom metric label
          label = if key.match(/^cpu.usage/)
            "CPU " + metric.display_name()
          else if key.match(/^cpu.loadavg/)
            "CPU Load <br>" + metric.display_name()
          else if key == "mem.usage"
            "Memory " + metric.display_name()
          else if key == "fs.disk.usage"
            "Disk Usage (%) on " +  metric.get("tags").mount
          else
            metric.display_name()

          __out__ += @include_partial(_bvm.SparkLine, {host: @host, metric: metric, metric_label: label})
