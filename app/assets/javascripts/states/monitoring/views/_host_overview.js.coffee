namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.HostOverview extends Stark.Partial
    className: "host_overview"
    template: "monitoring/_host_overview"

    links:
      "h3 a": [ "mon_view_host", (el) -> { host: @host, metrics: (new _bm.HostSummaryMetricList()).reset(@metrics) } ]

    events:
      "mousemove td.sparkline": (e) ->
        return if !$(e.target).hasClass("sparkline")
        xline = @$("div.line.xline")
        h = @$("table.metrics").height()
        oX = @$("div.graph").offsetParent().offset().left
        x = e.clientX - oX

        gX = @$("div.graph").offset().left
        gW = @metrics[0].graph.getArea().w
        lowerBound = gX - oX
        upperBound = lowerBound + gW
        if x < gX
          x = lowerBound
        else if x > upperBound + 10
          xline.hide()
          return
        else if x > upperBound
          x = upperBound

        xline.css({
          height: h-9+"px"
          top:    "9px"
          left:   x + "px"
        })
        xline.show()

      "mouseout td.sparkline": (e) ->
        @$("div.line.xline").hide()


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
