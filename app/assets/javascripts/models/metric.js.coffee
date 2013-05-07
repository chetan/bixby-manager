
namespace 'Bixby.model', (exports, top) ->

  class exports.Metric extends Stark.Model

    initialize: (attributes, options) ->
      super
      @extract_param(attributes, "metric", true)
      @extract_param(attributes, "host")

    url: ->
      host_id = @host_id || @get("host_id")
      id = @id || @get("id")
      s = "/monitoring/hosts/#{host_id}/metrics/#{id}?"
      if @get("start")
        s += "&start=" + @get("start")
      if @get("end")
        s += "&end=" + @get("end")
      if @get("downsample")
        s += "&downsample=" + @get("downsample")
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
    url: -> "/monitoring/hosts/#{@host_id}/metrics"

    initialize: (data) ->
      @extract_param(data, "host")
