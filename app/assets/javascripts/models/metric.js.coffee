
namespace 'Bixby.model', (exports, top) ->

  class exports.Metric extends Stark.Model

    @key: "metric"
    params: [ { name: "metric", set_id: true }, "host" ]

    urlRoot: ->
      host_id = @host_id || @get("host_id")
      "/rest/hosts/#{host_id}/metrics"

    url: ->
      s = super() + "?"
      if @get("start")
        s += "&start=" + @get("start")
      if @get("end")
        s += "&end=" + @get("end")
      if @get("downsample")
        s += "&downsample=" + @get("downsample")
      return s

    display_tags: ->
      label = @get("label")
      return if label? && label.match(/\$/) # skip labels with vars
      tags = _.omit(@get("tags"), ["tenant_id", "org_id", "host_id", "host", "check_id"])
      _.map(tags, (v, k) -> "#{k}=#{v}").join(", ")


    # Get the display name
    # e.g., "Disk Usage (%)"
    display_name: ->
      s = null

      if @get("label")
        tags = @get("tags")
        l = @get("label")
        matches = _.getMatches(l, /(^|[\b\s])\$([\w]+)\b/g, 2)

        _.each matches, (m) ->
          tag = tags[m]
          if tag
            l = l.replace("$#{m}", tag)

        s = l

      else
        s = @get("name") || @get("desc")

      if @get("unit")
        s = s + " (" + @get("unit") + ")"

      return s

    # Create a condensed metric label with relevant tags included
    custom_display_name: (add_br) ->
      br = if add_br
        "<br>"
      else
        ""
      key = @get("key")
      label = if key.match(/^cpu.usage/)
        "CPU " + @display_name()
      else if key.match(/^cpu.loadavg/)
        "CPU Load " + br + @display_name()
      else if key == "mem.usage"
        "Memory " + @display_name()
      else if key == "fs.disk.usage"
        "Disk Usage (%) on " + br +  @get("tags").mount
      else if key.match(/^net.[rt]x.bytes/)
        @display_name() + " on " + @get("tags").interface
      else
        @display_name()

      return label

    # Get the range attribute for this metric
    get_range: ->
      if !@get("key").match(/^cpu.loadavg/)
        return @get("range")

      # custom range only for loadavg
      # if all values < 1, returns "0..1", else null
      larger = false
      _.each @get("data"), (p) ->
        if p.y > 1
          larger = true
          return
      if larger
        return null
      else
        return "0..1"

    # Get a formatted value as a string for display
    # e.g., "10.53% @ 2014/08/22 14:19:42"
    format_value: (val, date) ->
      unit_label = ""
      unit = @get("unit")
      if unit?
        if unit == "%"
          unit_label = "%"
        else
          unit_label = " " + unit

      date = moment(date) if !moment.isMoment(date)
      date.format("L HH:mm:ss")
      val = Bixby.monitoring.Graph.format_value(val)

      return _.str.sprintf("%s%s @ %s", val, unit_label, date)

    # get only the metric attributes (the actual data elements)
    # { key, tags, vals: [ {time, val}, ... ]}
    metrics: ->
      metrics = []
      _.each @attributes, (v, k) ->
        if _.isObject(v)
          metrics.push(v)

      return metrics

    # Return list of tuples with time in millisec
    tuples: ->
      vals = _.map _.sortBy(@get("data"), "x"), (v) ->
        [ new Date(v.x * 1000), v.y ]


  class exports.MetricList extends Stark.Collection
    model: exports.Metric
    @key: "metrics"
    url: -> "/rest/hosts/#{@host_id}/metrics"
    params: [ "host" ]

    comparator: (metric) ->
      metric.display_name()

  class exports.CheckMetricList extends exports.MetricList
    params: [ { name: "metric", set_id: true }, "host", "check" ]
    url: -> "/rest/hosts/#{@host_id}/checks/#{@check_id}/metrics"

  class exports.HostSummaryMetricList extends exports.MetricList
    url: -> "/rest/hosts/#{@host_id}/metrics/summary"

  class exports.SummaryMetricList extends exports.MetricList
    url: -> "/rest/metrics/summary"
