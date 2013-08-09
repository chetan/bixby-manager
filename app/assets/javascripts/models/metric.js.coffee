
namespace 'Bixby.model', (exports, top) ->

  class exports.Metric extends Stark.Model

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
      vals = _.map @get("data"), (v) ->
        [ new Date(v.x * 1000), v.y ]


  class exports.MetricList extends Stark.Collection
    model: exports.Metric
    url: -> "/rest/hosts/#{@host_id}/metrics"
    params: [ "host" ]
