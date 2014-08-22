
namespace 'Bixby.model', (exports, top) ->

  class exports.Metric extends Stark.Model

    @key: "metric"
    params: [ { name: "metric", set_id: true }, "host" ]

    # List all metrics for the given check
    #
    # @param [Integer] host_id
    # @param [Integer] check_id
    #
    # NOTE: not currently used. probably needs a callback to fetch
    @list_for_check: (host_id, check_id) ->
      metrics = new exports.MetricList()
      metrics.url = "/rest/hosts/#{host_id}/checks/#{check_id}/metrics"
      metrics.fetch() # TODO callback?

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

      date = new Date(date) if !_.isDate(date)
      date = strftime("%Y/%m/%d %H:%M:%S", date)
      val = Bixby.monitoring.format_value(val)

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

  class exports.HostSummaryMetricList extends exports.MetricList
    url: -> "/rest/hosts/#{@host_id}/metrics/summary"

  class exports.SummaryMetricList extends exports.MetricList
    url: -> "/rest/metrics/summary"
